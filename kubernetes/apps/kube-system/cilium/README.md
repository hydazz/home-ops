# Cilium

## UniFi BGP

Cilium announces LoadBalancer IPs to the UDM from every node. The peer
configuration uses a 3-second keepalive and 9-second hold time so a dead path
is withdrawn quickly. UniFi's FRR build does not include `bfdd`, so BFD is not
used.

```sh
router bgp 64513
  bgp router-id 192.168.1.1
  no bgp ebgp-requires-policy

  neighbor k8s peer-group
  neighbor k8s remote-as 64514

  neighbor 192.168.42.10 peer-group k8s
  neighbor 192.168.42.11 peer-group k8s
  neighbor 192.168.42.12 peer-group k8s

  bgp listen range 2403:5817:b73a:42::/64 peer-group k8s

  address-family ipv4 unicast
    maximum-paths 3
    neighbor k8s activate
    neighbor k8s next-hop-self
    neighbor k8s soft-reconfiguration inbound
  exit-address-family

  address-family ipv6 unicast
    maximum-paths 3
    neighbor k8s activate
    neighbor k8s next-hop-self
    neighbor k8s soft-reconfiguration inbound
  exit-address-family
exit
```

`maximum-paths 3` enables ECMP across the three nodes. Uploading the FRR
configuration briefly resets the BGP sessions.

## UDM boot scripts

The UDM root filesystem is replaced by firmware updates. Install
[`udm-boot`](https://github.com/unifi-utilities/unifi-common) so customizations
can live on the persistent `/data` partition:

```sh
curl -fsL "https://raw.githubusercontent.com/unifi-utilities/unifi-common/HEAD/remote_install.sh" | /bin/bash
```

After each firmware update, check `systemctl is-enabled udm-boot` and rerun the
installer if needed.

### ECMP flow hashing

Set the kernel to include layer-four ports in its ECMP hash so connections from
one client can spread across the three next hops. Create
`/data/on_boot.d/30-ecmp-l4-hash.sh`:

```sh
#!/bin/sh
echo "net.ipv4.fib_multipath_hash_policy = 1" > /etc/sysctl.d/30-ecmp-l4-hash.conf
sysctl -w net.ipv4.fib_multipath_hash_policy=1
```

### HTTP/3 discovery

Envoy already serves HTTP/3. Publish DNS HTTPS records from dnsmasq so clients
can discover `h3` without first making an HTTP/2 request. Create
`/data/on_boot.d/40-dnsmasq-https-rr.sh`:

```sh
#!/bin/sh
CONF_DIR=/run/dnsmasq.dhcp.conf.d
for i in $(seq 1 30); do [ -d "$CONF_DIR" ] && break; sleep 2; done
[ -d "$CONF_DIR" ] || exit 0
cat > "$CONF_DIR/custom.conf" <<RR
dns-rr=external.hyde.services,65,00010000010006026833026832
dns-rr=internal.hyde.services,65,00010000010006026833026832
RR
[ -f /run/dnsmasq-main.pid ] && kill "$(cat /run/dnsmasq-main.pid)" 2>/dev/null
exit 0
```

Make both scripts executable, run them once, and verify with:

```sh
vtysh -c "show bgp summary"
dig +short @192.168.1.1 internal.hyde.services HTTPS
curl --http3-only -sk -o /dev/null -w '%{http_version}\n' https://internal.hyde.services/
```
