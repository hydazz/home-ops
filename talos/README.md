# Talos

The cluster machine configuration is composed from multi-document patches:

- `cluster.yaml.j2` contains configuration shared by every node.
- `controlplane.yaml.j2` contains control-plane-only configuration.
- `nodes/<role>/<node>.yaml.j2` contains the hostname and hardware selectors.
- `schematic.yaml.j2` defines the shared Image Factory schematic.

`just talos render-config <node>` renders each layer through strict Minijinja,
resolves its `op://` references with `op inject`, and merges the documents with
`talosctl machineconfig patch`.

The recipe restores the explicit empty DNS-search list after merging because
Talos drops it when re-encoding. Apply the complete rendered config; `patch mc`
or `edit mc` can lose the override again. Existing pods need recreation to pick
up the changed search list. Hugepages remain reserved for PostgreSQL.

All current nodes are control planes. Adding a worker requires a
`workers.yaml.j2` role patch and a node file under `nodes/workers/`.

The CA certificate and key fields merge as a unit. Role patches that add a CA
key must repeat the certificate or the patch will blank it.

Common commands:

```sh
just talos render-config <node>
just talos apply-node <node>
just talos upgrade-node <node>
just talos upgrade-k8s <version>
just talos download-image <version>
```
