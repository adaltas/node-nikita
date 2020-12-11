
# `nikita.lxd.cluster`

Create a cluster of LXD instances.

## Example

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
      #id_rsa: assets/id_rsa
    user:
      nikita:
        sudo: true
        authorized_keys: assets/id_rsa.pub
    prevision: path/to/action
    provision: path/to/action
    provision_container: path/to/action
```

## Schema

    schema =
      type: 'object'
      properties:
        'containers':
          type: 'object'
          description: """
          Initialize a Linux Container with given image name, container name and
          config.
          """
          patternProperties: '(^[a-zA-Z][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9](?!\-)$)|(^[a-zA-Z]$)':
            type: 'object'
            properties:
              'config':
                $ref: 'module://@nikitajs/lxd/src/config/set#/properties/config'
              'disk':
                type: 'object'
                default: {}
                patternProperties: '':
                  $ref: 'module://@nikitajs/lxd/src/config/device#/properties/config'
              'image':
                $ref: 'module://@nikitajs/lxd/src/init#/properties/image'
              'nic':
                type: 'object'
                default: {}
                patternProperties: '':
                  type: 'object'
                  properties:
                    'config':
                      $ref: 'module://@nikitajs/lxd/src/config/device#/properties/config'
                    'ip':
                      type: 'string'
                      format: 'ipv4'
                    'netmask':
                      type: 'string'
                      default: '255.255.255.0'
                      format: 'ipv4'
              'proxy':
                type: 'object'
                default: {}
                patternProperties: '':
                  $ref: 'module://@nikitajs/lxd/src/config/device#/properties/config'
              'user':
                type: 'object'
                default: {}
                patternProperties: '':
                  type: 'object'
                  properties:
                    'sudo':
                      type: 'boolean'
                      default: false
                      description: """
                      Enable sudo access for the user.
                      """
                    'authorized_keys':
                      type: 'string'
                      description: """
                      Path to file with SSH public key to be added to
                      authorized_keys file.
                      """
              'ssh':
                type: 'object'
                default: {}
                properties:
                  'enable':
                    type: 'boolean'
                    default: false
                    description: """
                    Enable SSH connection.
                    """
            required: ['image']
        'networks':
          type: 'object'
          default: {}
          patternProperties: '':
            $ref: 'module://@nikitajs/lxd/src/network#/properties/config'
        'prevision':
          typeof: 'function'
        'provision':
          typeof: 'function'
        'provision_container':
          typeof: 'function'
      required: ['containers']

## Handler

    handler = ({config}) ->
      config_orig = config
      # Prevision
      if !!config_orig.prevision
        @call config_orig, config_orig.prevision
      # Create a network
      for network, config of config_orig.networks then @call
        config:
          header: "Network #{network}"
          network: network
          config: config
      , ({config : {network, config}}) ->
        @lxd.network
          header: 'Create'
          network: network
          config: config
      # Init containers
      for container, config of config_orig.containers then @call
        config:
          header: "Container #{container}"
          container: container
          config: config
      , ({config : {container, config}}) ->
        # Set configuration
        @lxd.init
          header: 'Init'
          container: container
          image: config.image
        # Set config
        if config?.config
          @lxd.config.set
            config:
              header: 'Config'
              container: container
              config: config.config
        # Create disk device
        for device, configdisk of config.disk
          @lxd.config.device
            config:
              header: "Device #{device} disk"
              container: container
              device: device
              type: 'disk'
              config: configdisk
        # Create nic device
        for device, confignic of config.nic
          confignic.name ?= device
          # note: `confignic.config.parent` is not required for each type
          # throw Error "Required Property: nic.#{device}.parent" unless confignic.config.parent
          @lxd.config.device
            config:
              header: "Device #{device} nic"
              container: container
              device: device
              type: 'nic'
              config: confignic.config
          if !!confignic.ip
            @lxd.file.push
              header: "ifcfg #{confignic.name}"
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
        # Create proxy device
        for device, configproxy of config.proxy
          # todo: add host detection and port forwarding to VirtualBox
          # VBoxManage controlvm 'lxd' natpf1 'ipa_ui,tcp,0.0.0.0,2443,,2443'
          @lxd.config.device
            config:
              header: "Device #{device} proxy"
              container: container
              device: device
              type: 'proxy'
              config: configproxy
        # Start container
        @lxd.start
          header: 'Start'
          container: container
        # Wait until container is running
        @execute.wait
          command: "lxc info #{container} | grep 'Status: Running'"
        @network.tcp.wait
          host: 'linuxfoundation.org'
          port: 80
          # timeout: 5000
        # Not sure why openssl is required
        @lxd.exec
          header: 'OpenSSL'
          container: container
          command: """
          #yum update -y
          yum install -y openssl
          command -v openssl
          """
          metadata:
            retry: 10
            sleep: 5000
          trap: true
        # Enable SSH
        if config.ssh.enabled
          @lxd.exec
            header: 'SSH'
            container: container
            command: """
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
        # Create users
        for user, configuser of config.user
          header: "User #{user}"
          @lxd.exec
            header: 'Create'
            container: container
            command: """
            id #{user} && exit 42
            useradd --create-home --system #{user}
            mkdir -p /home/#{user}/.ssh
            chown #{user}.#{user} /home/#{user}/.ssh
            chmod 700 /home/#{user}/.ssh
            """
            trap: true
            code_skipped: 42
          # Enable sudo access
          if configuser.sudo
            @lxd.exec
              header: 'Sudo'
              container: container
              command: """
              yum install -y sudo
              command -v sudo
              cat /etc/sudoers | grep "#{user}" && exit 42
              echo "#{user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
              """
              trap: true
              code_skipped: 42
          # Add SSH public key to authorized_keys file
          if configuser.authorized_keys
            @lxd.file.push
              header: 'Authorize'
              container: container
              gid: "#{user}"
              uid: "#{user}"
              mode: 600
              source: "#{configuser.authorized_keys}"
              target: "/home/#{user}/.ssh/authorized_keys"
      # Provision
      if !!config_orig.provision
        @call config_orig, config_orig.provision
      # Provision containers
      if !!config_orig.provision_container
        for container, config of config_orig.containers
          @call container: container, config: config
          , config_orig.provision_container

## Export

    module.exports =
      handler: handler
      schema: schema
