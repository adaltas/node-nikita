

# Cluster

## Exemple

```yaml
network:
  lxdbr0public:
    ipv4.address: 172.16.0.1/24
    ipv4.nat: true
    ipv6.address: none
  lxdbr1private:
    ipv4.address: 10.10.10.1/24
    ipv4.nat: true
    ipv6.address: none
    dns.domain: nikita
containers:
  nikita
    image: images:centos/7
    config:
      environment:
        MY_VAR: 'my value'
    disk:
      nikitadir:
        source: /nikita
        path: /nikita
    nic:
      eth0:
        config:
          name: eth0
          nictype: bridged
          parent: lxdbr0public
      eth1:
        config:
          name: eth1
          nictype: bridged
          parent: lxdbr1private
          ip: '10.10.10.10'
          netmask: '255.255.255.192'
    proxy:
      ssh:
        listen: tcp:0.0.0.0:2200
        connect: tcp:127.0.0.1:22
    ssh:
      enabled: true
      id_rsa: assets/id_rsa
    user:
      nikita:
        sudo: true
        authorized_keys: assets/id_rsa.pub
    prevision: path/to/action
    provision: path/to/action
    provision_container: path/to/action
```

    module.exports = ({options}) ->
      options.network ?= {}
      options.proxy ?= {}
      options.user ?= {}
      @call
        if: options.prevision
      , options,  options.prevision
      for network, config of options.network
        @lxd.network
          header: 'Bridge'
          network: network
          config: config
      for container, config of options.containers
        config.config ?= {}
        ssh = config.ssh or {}
        ssh.enabled ?= false
        # throw Error 'Required Option: ssh.id_rsa is record if ssh is enabled' if ssh.enabled and not ssh.id_rsa
        @lxd.init
          header: 'Init'
          name: container
          image: config.image
        @lxd.config.set
          header: 'Config'
          name: container
          image: config.image
          config: config.config
        for device, configdisk of config.disk
          @lxd.config.device.add
            header: "Device #{device} disk"
            name: container
            device: device
            type: 'disk'
            config: configdisk
        for device, confignic of config.nic
          confignic.name ?= device
          confignic.netmask ?= '255.255.255.0'
          throw Error "Required Property: nic.#{device}.parent" unless confignic.config.parent
          @lxd.config.device.add
            header: "Device #{device} nic"
            name: container
            device: device
            type: 'nic'
            config: confignic.config
          @lxd.file.push
            header: "ifcfg #{confignic.name}"
            if: confignic.ip
            name: container
            target: "/etc/sysconfig/network-scripts/ifcfg-#{confignic.name}"
            content: """
            NM_CONTROLLED=yes
            BOOTPROTO=none
            ONBOOT=yes
            IPADDR=#{confignic.ip}
            NETMASK=#{confignic.netmask}
            DEVICE=#{confignic.name}
            PEERDNS=no
            """
        for device, configproxy of config.proxy
          @lxd.config.device.add
            header: "Device #{device} proxy"
            name: container
            device: device
            type: 'proxy'
            config: configproxy
        @lxd.start
          header: 'Start'
          name: container
        @lxd.exec
          header: 'OpenSSL'
          name: container
          cmd: """
          yum update -y
          yum install -y openssl
          command -p openssl
          """
          retry: 3
          trap: true
        @lxd.exec
          header: 'SSH'
          if: ssh.enabled
          name: container
          cmd: """
          systemctl status sshd
          yum install -y openssh-server
          systemctl start sshd
          systemctl enable sshd
          """
          trap: true
          code_skipped: 4
        for user, configuser of config.user then @call header: "#{user}", ->
          @lxd.exec
            header: "User #{user}"
            name: container
            cmd: """
            id #{user} && exit 42
            useradd --create-home --system #{user}
            mkdir -p /home/#{user}/.ssh
            chown #{user}.#{user} /home/#{user}/.ssh
            chmod 700 /home/#{user}/.ssh
            """
            trap: true
            code_skipped: 42
          @lxd.exec
            header: 'Sudo'
            if: configuser.sudo
            name: container
            cmd: """
            yum install -y sudo
            command -p sudo
            cat /etc/sudoers | grep "#{user}" && exit 42
            echo "#{user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
            """
            trap: true
            code_skipped: 42
          @lxd.file.push
            header: 'Authorize'
            if: configuser.authorized_keys
            name: container
            gid: "#{user}"
            uid: "#{user}"
            mode: 600
            source: "#{configuser.authorized_keys}"
            target: "/home/#{user}/.ssh/authorized_keys"
      @call
        if: options.provision
      , options,  options.provision
      for container, config of options.containers
        @call
          if: !!options.provision_container
        , container: container, config: config
        , options.provision_container
      
