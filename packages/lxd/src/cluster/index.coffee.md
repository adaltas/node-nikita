
# `nikita.lxd.cluster`

Attach an existing network to a container.

## Options

* `networks` (required, object)   
  Create or update network configurations.
* `containers` (required, object)   
  Initialize a Linux Container with given image name, container name and options.


# Cluster

## Exemple

```yaml
networks:
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
          container: eth0
          nictype: bridged
          parent: lxdbr0public
      eth1:
        config:
          container: eth1
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
      options.networks ?= {}
      options.proxy ?= {}
      options.user ?= {}
      @call
        if: !!options.prevision
      , options,  options.prevision
      for network, config of options.networks
        @lxd.network
          header: 'Bridge'
          network: network
          config: config
      for container, config of options.containers then @call
        header: "Container #{container}"
        container: container
        config: config
      , ({options : {container, config}}) ->
        validate_container_name container
        config.config ?= {}
        ssh = config.ssh or {}
        ssh.enabled ?= false
        @lxd.init
          header: 'Init'
          container: container
          image: config.image
        @lxd.config.set
          header: 'Config'
          container: container
          image: config.image
          config: config.config
        for device, configdisk of config.disk
          @lxd.config.device
            header: "Device #{device} disk"
            container: container
            device: device
            type: 'disk'
            config: configdisk
        for device, confignic of config.nic
          confignic.name ?= device
          confignic.netmask ?= '255.255.255.0'
          throw Error "Required Property: nic.#{device}.parent" unless confignic.config.parent
          @lxd.config.device
            header: "Device #{device} nic"
            container: container
            device: device
            type: 'nic'
            config: confignic.config
          @lxd.file.push
            header: "ifcfg #{confignic.name}"
            if: !!confignic.ip
            container: container
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
          # todo: add host detection and port forwarding to VirtualBox
          # VBoxManage controlvm 'lxd' natpf1 'ipa_ui,tcp,0.0.0.0,2443,,2443'
          @lxd.config.device
            header: "Device #{device} proxy"
            container: container
            device: device
            type: 'proxy'
            config: configproxy
        @lxd.start
          header: 'Start'
          container: container
        @wait.execute
          cmd: "lxc info #{container} | grep 'Status: Running'"
        @connection.wait
          host: 'linuxfoundation.org'
          port: 80
          # timeout: 5000
        # Not sure why openssl is required
        @lxd.exec
          header: 'OpenSSL'
          container: container
          cmd: """
          #yum update -y
          yum install -y openssl
          command -v openssl
          """
          retry: 10
          sleep: 5000
          trap: true
        @lxd.exec
          header: 'SSH'
          if: ssh.enabled
          container: container
          cmd: """
          # systemctl status sshd
          # yum install -y openssh-server
          # systemctl start sshd
          # systemctl enable sshd
          systemctl status sshd && exit 42
          if command -v yum >/dev/null 2>&1; then
            yum -y install openssh-server
          elif command -v apt-get >/dev/null 2>&1; then
            apt-get -y install openssh-server
          else
            echo "Unsupported Package Manager" >&2 && exit 2
          fi
          systemctl status sshd && exit 42
          systemctl start sshd
          systemctl enable sshd
          """
          trap: true
          code_skipped: 42
        for user, configuser of config.user then @call
          header: "User #{user}"
          user: user
          configuser: configuser
        , ({options = {user, configuser}}) ->
          @lxd.exec
            header: 'Create'
            container: container
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
            container: container
            cmd: """
            yum install -y sudo
            command -v sudo
            cat /etc/sudoers | grep "#{user}" && exit 42
            echo "#{user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
            """
            trap: true
            code_skipped: 42
          @lxd.file.push
            header: 'Authorize'
            if: configuser.authorized_keys
            container: container
            gid: "#{user}"
            uid: "#{user}"
            mode: 600
            source: "#{configuser.authorized_keys}"
            target: "/home/#{user}/.ssh/authorized_keys"
      @call
        if: !!options.provision
      , options,  options.provision
      for container, config of options.containers
        @call
          if: !!options.provision_container
        , container: container, config: config
        , options.provision_container

## Dependencies

    validate_container_name = require '../misc/validate_container_name'
      
