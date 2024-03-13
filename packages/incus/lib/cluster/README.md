
# `nikita.incus.cluster`

Create a cluster of LXD instances.

## Example

```yaml
networks:
  incusbr0public:
    ipv4.address: 172.16.0.1/24
    ipv4.nat: true
    ipv6.address: none
  incusbr1private:
    ipv4.address: 10.10.10.1/24
    ipv4.nat: true
    ipv6.address: none
    dns.domain: nikita.local
containers:
  nikita:
    image: images:centos/7
    properties:
      environment:
        MY_VAR: 'my value'
    disk:
      nikitadir:
        source: /nikita
        path: /nikita
    nic:
      eth0:
        container: eth0
        nictype: bridged
        parent: incusbr0public
      eth1:
        container: eth1
        nictype: bridged
        parent: incusbr1private
        ipv4.address: '10.10.10.10'
    proxy:
      ssh:
        listen: 'tcp:0.0.0.0:2200'
        connect: 'tcp:127.0.0.1:22'
    ssh:
      enabled: true
      #id_rsa: assets/id_rsa
    user:
      nikita:
        sudo: true
        authorized_keys: assets/id_rsa.pub
    prevision: path/to/action
    provision: path/to/action
    provision_container: path/to/action
```
