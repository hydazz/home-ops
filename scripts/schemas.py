# rather dodgy but does the job (needs prettier ran afterwards)

import os
import re
import subprocess
import requests
from pathlib import Path
import yaml

ROOT = Path.cwd()
SCHEMA_SERVERS = [
    "https://kubernetes-schemas.pages.dev/",
    "https://homelab-schemas-epg.pages.dev/",
    "https://schemas.hydaz.com/"
]
KUSTOMIZATION = "https://json.schemastore.org/kustomization"
APP_TEMPLATE = "https://raw.githubusercontent.com/bjw-s-labs/helm-charts/main/charts/other/app-template/schemas/helmrelease-helm-v2.schema.json"


def find_yaml_files(root):
    return [p for p in root.rglob("*.yaml")] + [p for p in root.rglob("*.yml")]


def schema_path(api_version, kind):
    group, version = api_version.split("/", 1) if "/" in api_version else ("core", api_version)
    return f"{group.lower()}/{kind.lower()}_{version.lower()}.json"


def get_schema_url(api_version, kind, lines):
    try:
        obj = yaml.safe_load("\n".join(lines))
        if kind == "HelmRelease" and isinstance(obj, dict):
            chart_name = obj.get("spec", {}).get("chartRef", {}).get("name", "")
            if chart_name == "app-template":
                return APP_TEMPLATE
    except Exception:
        pass

    if kind == "Kustomization":
        if "kustomize.toolkit.fluxcd.io" in api_version:
            path = schema_path(api_version, kind)
            return check_schema(path)
        else:
            return KUSTOMIZATION
    else:
        path = schema_path(api_version, kind)
        return check_schema(path)


def check_schema(path):
    for base in SCHEMA_SERVERS:
        full = base + path
        try:
            r = requests.head(full, timeout=3)
            if r.status_code == 200:
                return full
        except requests.RequestException:
            continue
    return None


def process_file(path):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    trailing_newline = content.endswith("\n")

    docs_raw = re.split(r'(?m)^---\s*\n?', content.strip())
    updated_docs = []

    for doc in docs_raw:
        lines = doc.strip().splitlines()

        # Move trailing schema line (if any)
        if lines and lines[-1].startswith("# yaml-language-server: $schema="):
            lines.pop()

        api_version = None
        kind = None
        for line in lines:
            if line.strip().startswith("apiVersion:"):
                api_version = line.split(":", 1)[1].strip()
            elif line.strip().startswith("kind:"):
                kind = line.split(":", 1)[1].strip()
            if api_version and kind:
                break

        if api_version and kind:
            schema_url = get_schema_url(api_version, kind, lines)
            if schema_url:
                lines = [l for l in lines if not l.startswith("# yaml-language-server: $schema=")]
                lines.insert(0, f"# yaml-language-server: $schema={schema_url}")

        updated_docs.append("\n".join(lines))

    new_content = "\n---\n".join(updated_docs)
    if trailing_newline:
        new_content += "\n"

    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)

    # Run Prettier to format
    # try:
    #    subprocess.run(["prettier", "--write", str(path)], check=True)
    # except subprocess.CalledProcessError as e:
    #    print(f"❌ Prettier failed on {path}: {e}")
    # except FileNotFoundError:
    #    print("⚠️ Prettier not found. Please install it with `npm install -g prettier`.")

    print(f"✅ Updated {path}")


def main():
    for file in find_yaml_files(ROOT):
        try:
            process_file(file)
        except Exception as e:
            print(f"❌ Failed {file}: {e}")


if __name__ == "__main__":
    main()
