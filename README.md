<div align="center">

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Kubernetes_logo_without_workmark.svg/1234px-Kubernetes_logo_without_workmark.svg.png" align="center" width="175px" height="175px"/>

### <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f680/512.gif" alt="🚀" width="16" height="16"> My Home Operations Repository <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f6a7/512.gif" alt="🚧" width="16" height="16">

_... managed with Flux, Renovate, and GitHub Actions_ <img src="https://fonts.gstatic.com/s/e/notoemoji/latest/1f916/512.gif" alt="🤖" width="16" height="16">

</div>

<div align="center">

[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Ftalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://talos.dev)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://kubernetes.io)&nbsp;&nbsp;
[![Flux](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fflux_version&style=for-the-badge&logo=flux&logoColor=white&color=blue&label=%20)](https://fluxcd.io)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/hydazz/home-ops/renovate.yaml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/hydazz/home-ops/actions/workflows/renovate.yaml)

</div>

<div align="center">

[![Home-Internet](https://img.shields.io/endpoint?url=https%3A%2F%2Fspoodermon.hyde.services%2Fapi%2Fv1%2Fendpoints%2F_ping%2Fhealth%2Fbadge.shields&style=for-the-badge&logo=ubiquiti&logoColor=white&label=Home%20Internet)](https://gatus.hyde.services)&nbsp;&nbsp;
[![Status-Page](https://img.shields.io/endpoint?url=https%3A%2F%2Fspoodermon.hyde.services%2Fapi%2Fv1%2Fendpoints%2F_status-page%2Fhealth%2Fbadge.shields&style=for-the-badge&logo=statuspage&logoColor=white&label=Status%20Page)](https://gatus.hyde.services)&nbsp;&nbsp;
[![Alertmanager](https://img.shields.io/endpoint?url=https%3A%2F%2Fspoodermon.hyde.services%2Fapi%2Fv1%2Fendpoints%2F_heartbeat%2Fhealth%2Fbadge.shields&style=for-the-badge&logo=prometheus&logoColor=white&label=Alertmanager)](https://gatus.hyde.services)

</div>

<div align="center">

[![Age-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fcluster_age_days&style=flat-square&label=Age)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Uptime-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fcluster_node_count&style=flat-square&label=Nodes)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fcluster_pod_count&style=flat-square&label=Pods)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fcluster_cpu_usage&style=flat-square&label=CPU)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Memory-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fcluster_memory_usage&style=flat-square&label=Memory)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Power-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fcluster_power_usage&style=flat-square&label=Power)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Alerts](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.hyde.services%2Fcluster_alert_count&style=flat-square&label=Alerts)](https://github.com/kashalls/kromgo)

</div>

---

# What's in the rack:

### 🖥️ Compute

| Node             | CPU       | Memory | Storage                                      | GPU              | OS      | Case                 | Function                       |
| ---------------- | --------- | ------ | -------------------------------------------- | ---------------- | ------- | -------------------- | ------------------------------ |
| nebula           | i7-12700K | 32GB   | 1TB Boot                                     |                  | Proxmox | SilverStone RM21-308 | Hypervisor                     |
| └─ picard        | 4 vCPU    | 8GB    | 16GB Boot + 4×4TB (Slow) + 1x1TB NVMe (Fast) |                  | TrueNAS |                      | Media/file storage and backups |
| └─ x86-builder-1 | 8 vCPU    | 8GB    | 16GB Boot + 64GB Docker Disk                 |                  | Debian  |                      | Docker builds                  |
|                  |           |        |                                              |                  |         |                      |
| discovery        | i7-14700K | 64GB   | 500GB Boot + 1TB Ceph                        | RTX 4060 Ti 16GB | Talos   | SilverStone RM400    | Talos node with da GPU         |
| voyager          | i7-13700K | 64GB   | 500GB Boot + 1TB Ceph                        |                  | Talos   | SilverStone RM23-502 |                                |
| titan            | i7-12700K | 64GB   | 500GB Boot + 1TB Ceph                        |                  | Talos   | SilverStone RM23-502 |                                |

### 🌐 Networking

| Device             | Model              | Details                         |
| ------------------ | ------------------ | ------------------------------- |
| Router/NVR         | UDM Pro Max        | 8TB HDD for NVR                 |
| Aggregation Switch | USW-Aggregation    | 8× SFP+                         |
| Core Switch        | USW Pro Max 24 PoE | Does some switching and powring |

### 🔌 Other

| Device | Model                 | Details                                                                               |
| ------ | --------------------- | ------------------------------------------------------------------------------------- |
| IP KVM | Geekworm X680         | 4-port HDMI + USB KVM                                                                 |
| UPS    | Eaton 5PX Gen2 1500VA | Burnt a hole through the carpet trying to DIY an EBM (luckly the rack hides the hole) |

---

### 💸 Dependencies/Costings

| Service                                 | Function                                                      | Cost ($AUD)           |
| --------------------------------------- | ------------------------------------------------------------- | --------------------- |
| [1Password](https://1password.com/)     | Secrets with [External Secrets](https://external-secrets.io/) | Free courtesy of work |
| [Cloudflare](https://cloudflare.com/)   | Domain/Proxying/CDN/R2                                        | Free (+domains)       |
| [Newshosting](https://newshosting.com/) | Usenet                                                        | $189.67/yr (for now?) |
| [TorGuard](https://torguard.net/)       | VPN                                                           | $7.65/month           |
| [GitHub](https://github.com/)           | Hosting this repository and CI/CD                             | Free                  |
| [Backblaze](https://backblaze.com/)     | Offsite backups of everything                                 | ~$4.82/month (735GB)  |
| Energy Usage                            | Cost of running Rack + PoE devices                            | ~$2/day (~10kW)       |
