<div align="center">

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Kubernetes_logo_without_workmark.svg/3840px-Kubernetes_logo_without_workmark.svg.png" align="center" width="175px" height="175px"/>

### <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f680/512.gif" alt="🚀" width="16" height="16"> My Home Operations Repository <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f6a7/512.gif" alt="🚧" width="16" height="16">

_... managed with Flux, Renovate, and GitHub Actions_ <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f916/512.gif" alt="🤖" width="16" height="16">

</div>

<div align="center">

[![Home-Internet](https://kromgo.hyde.services/badges/buddy_ping)](https://status.hyde.services)&nbsp;&nbsp;
[![Status-Page](https://kromgo.hyde.services/badges/buddy_status_page)](https://status.hyde.services)&nbsp;&nbsp;
[![Alertmanager](https://kromgo.hyde.services/badges/buddy_heartbeat)](https://status.hyde.services)

</div>

<div align="center">

[![Talos](https://kromgo.hyde.services/badges/talos_version)](https://talos.dev)&nbsp;&nbsp;
[![Kubernetes](https://kromgo.hyde.services/badges/kubernetes_version)](https://kubernetes.io)&nbsp;&nbsp;
[![Flux](https://kromgo.hyde.services/badges/flux_version)](https://fluxcd.io)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/onedr0p/home-ops/renovate.yaml?branch=main&label&logo=renovate&color=blue)](https://github.com/onedr0p/home-ops/actions/workflows/renovate.yaml)

</div>

<div align="center">

[![Age](https://kromgo.hyde.services/badges/cluster_birth_age)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
[![Uptime](https://kromgo.hyde.services/badges/cluster_uptime_age)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
[![Nodes](https://kromgo.hyde.services/badges/cluster_node_count)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
[![Pods](https://kromgo.hyde.services/badges/cluster_pod_count)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
[![CPU](https://kromgo.hyde.services/badges/cluster_cpu_usage)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
[![Memory](https://kromgo.hyde.services/badges/cluster_memory_usage)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
[![Power](https://kromgo.hyde.services/badges/cluster_power_usage)](https://github.com/home-operations/kromgo)&nbsp;&nbsp;
[![Alerts](https://kromgo.hyde.services/badges/cluster_alert_count)](https://github.com/home-operations/kromgo)

</div>

---

# What's in the rack:

### 🖥️ Compute

| Node      | CPU        | Memory | Storage                                        | OS      | Case                 | Function                       |
| --------- | ---------- | ------ | ---------------------------------------------- | ------- | -------------------- | ------------------------------ |
| picard    | i7-12700K  | 64GB   | 2x1TB Mirror (Boot+Data)                       | Proxmox | SilverStone RM21-308 | Hypervisor                     |
| └─ data   | 4 vCPUs    | 16GB   | 64GB Boot 4x4TB+1TB (Array) + 2x2TB SSD (Data) | TrueNAS |                      | Media/file storage and backups |
| -         |            |        |                                                |         |                      |                                |
| discovery | Ultra 245k | 64GB   | 1TB Boot + 1TB Ceph                            | Talos   | SilverStone RM23-502 |                                |
| voyager   | Ultra 250k | 64GB   | 500GB Boot + 1TB Ceph                          | Talos   | SilverStone RM23-502 |                                |
| titan     | Ultra 250k | 64GB   | 500GB Boot + 1TB Ceph                          | Talos   | SilverStone RM23-502 |                                |

### 🌐 Networking

| Device             | Model              | Details                        |
| ------------------ | ------------------ | ------------------------------ |
| Router/NVR         | UDM Pro Max        | 8TB HDD for NVR                |
| Aggregation Switch | USW-Aggregation    | 8x SFP+                        |
| Core Switch        | USW Pro Max 24 PoE | 16x GbE 8x + 2.5 GbE + 2x SFP+ |

### 🔌 Other

| Device | Model                 | Details                                                                               |
| ------ | --------------------- | ------------------------------------------------------------------------------------- |
| IP KVM | Geekworm X680         | 4-port HDMI + USB KVM                                                                 |
| UPS    | Eaton 5PX Gen2 1500VA | Burnt a hole through the carpet trying to DIY an EBM (luckly the rack hides the hole) |

---

### 💸 Dependencies/Costings

| Service                                 | Function                                                      | Cost ($AUD)          |
| --------------------------------------- | ------------------------------------------------------------- | -------------------- |
| [1Password](https://1password.com/)     | Secrets with [External Secrets](https://external-secrets.io/) | Free                 |
| [Cloudflare](https://cloudflare.com/)   | Domain/Proxying/CDN/R2                                        | Free (+domains)      |
| [Newshosting](https://newshosting.com/) | Usenet                                                        | $189.67/yr           |
| [TorGuard](https://torguard.net/)       | VPN                                                           | $7.65/month          |
| [GitHub](https://github.com/)           | Hosting this repository and CI/CD                             | Free                 |
| [Backblaze](https://backblaze.com/)     | Offsite backups of everything                                 | ~$4.82/month (735GB) |
| Energy Usage                            | Cost of running Rack + PoE devices                            | ~$2/day (~10kW)      |

---

### 🙌 Credits

Everything in this repo is based on the awesome work at [onedr0p/home-ops](https://github.com/onedr0p/home-ops)
