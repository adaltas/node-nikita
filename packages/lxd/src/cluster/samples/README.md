
# LXD cluster samples

The first bridge is ok, it handle nat, dhcp and dns hostname. The second bridge `eth1` configured as `10.10.50.1/24` is not active. From the container:

```bash
ip addr show eth1
148: eth1@if149: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:16:3e:86:95:8a brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::216:3eff:fe86:958a/64 scope link 
       valid_lft forever preferred_lft forever

ip route show
default via 10.10.40.1 dev eth0 
10.10.40.0/24 dev eth0 proto kernel scope link src 10.10.40.28 
169.254.0.0/16 dev eth0 scope link metric 1146
```

## Additionnal notes

Additionnal information are worth exploring in [Integration with systemd-resolved](https://github.com/lxc/lxd/blob/master/doc/networks.md#integration-with-systemd-resolved). Also, networkd could be configured on the host with

```
[Match]
Name=lxdbr0public

[Network]
DNS=172.16.0.1
Domains=~lxd

[Address]
Address=172.16.0.1/24
Gateway=172.16.0.1
```
