
# `nikita.lxc.cluster`

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
        parent: lxdbr0public
      eth1:
        container: eth1
        nictype: bridged
        parent: lxdbr1private
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

## Hooks

    on_action = 
      before: [
        '@nikitajs/core/src/plugins/metadata/schema'
      ]
      handler: ({config}) ->
        for name, container of config.containers
          container.container = name

## Schema definitions

    definitions =
      config:
        type: 'object'
        properties:
          'containers':
            type: 'object'
            description: '''
            Initialize a Linux Container with given image name, container name and
            config.
            '''
            patternProperties: '(^[a-zA-Z][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9](?!\-)$)|(^[a-zA-Z]$)':
              $ref: 'module://@nikitajs/lxd/src/init#/definitions/config'
              type: 'object'
              properties:
                'properties':
                  $ref: 'module://@nikitajs/lxd/src/config/set#/definitions/config/properties/properties'
                'disk':
                  type: 'object'
                  default: {}
                  patternProperties: '.*': # Device name of disk
                    $ref: 'module://@nikitajs/lxd/src/config/device#/definitions/disk/properties/properties'
                'nic':
                  type: 'object'
                  default: {}
                  patternProperties: '.*':
                    type: 'object'
                    allOf: [
                      properties:
                        'ip':
                          type: 'string'
                          format: 'ipv4'
                        'netmask':
                          type: 'string'
                          default: '255.255.255.0'
                          format: 'ipv4'
                    ,
                      $ref: 'module://@nikitajs/lxd/src/config/device#/definitions/nic/properties/properties'
                    ]
                'proxy':
                  type: 'object'
                  default: {}
                  patternProperties: '.*':
                    $ref: 'module://@nikitajs/lxd/src/config/device#/definitions/proxy/properties/properties'
                'user':
                  type: 'object'
                  default: {}
                  patternProperties: '.*':
                    type: 'object'
                    properties:
                      'sudo':
                        type: 'boolean'
                        default: false
                        description: '''
                        Enable sudo access for the user.
                        '''
                      'authorized_keys':
                        type: 'string'
                        description: '''
                        Path to file with SSH public key to be added to
                        authorized_keys file.
                        '''
                'ssh':
                  type: 'object'
                  default: {}
                  properties:
                    'enabled':
                      type: 'boolean'
                      default: false
                      description: '''
                      Enable SSH connection.
                      '''
          'networks':
            type: 'object'
            default: {}
            patternProperties: '.*':
              $ref: 'module://@nikitajs/lxd/src/network#/definitions/config/properties/properties'
          'prevision':
            typeof: 'function'
            description: '''
            A nikita action called before the container's creation.
            '''
          'prevision_container':
            typeof: 'function'
            description: '''
            A nikita action called for every container before it is created.
            '''
          'provision':
            typeof: 'function'
            description: '''
            A nikita action called after the container's creation.
            '''
          'provision_container':
            typeof: 'function'
            description: '''
            A nikita action called for every container after it is created.
            '''
        # required: ['containers']

## Handler

    handler = ({config}) ->
      # Prevision
      if !!config.prevision
        await @call config, config.prevision
      # Create a network
      for networkName, networkProperties of config.networks
        await @lxc.network
          $header: "Network #{networkName}"
          network: networkName
          properties: networkProperties
      # Prevision containers
      if !!config.prevision_container
        for containerName, containerConfig of config.containers
          await @call
            container: containerName
          , containerConfig
          , config.prevision_container
      # Init containers
      for containerName, containerConfig of config.containers then await @call
        $header: "Container #{containerName}"
      , ->
        # Set configuration
        await @lxc.init
          $header: 'Init'
          containerConfig
        # Set config
        if containerConfig?.properties
          await @lxc.config.set
            $header: 'Properties'
            container: containerName
            properties: containerConfig.properties
        # Create disk device
        for deviceName, configDisk of containerConfig.disk
          await @lxc.config.device
            $header: "Device #{deviceName} disk"
            container: containerName
            device: deviceName
            type: 'disk'
            properties: configDisk
        # Create nic device
        for deviceName, configNic of containerConfig.nic
          # note: `confignic.config.parent` is not required for each type
          # throw Error "Required Property: nic.#{device}.parent" unless confignic.config.parent
          await @lxc.config.device
            $header: "Device #{deviceName} nic"
            container: containerName
            device: deviceName
            type: 'nic'
            properties: utils.object.filter configNic, ['ip', 'netmask']
        # Create proxy device
        for deviceName, configProxy of containerConfig.proxy
          # todo: add host detection and port forwarding to VirtualBox
          # VBoxManage controlvm 'lxd' natpf1 'ipa_ui,tcp,0.0.0.0,2443,,2443'
          await @lxc.config.device
            $header: "Device #{deviceName} proxy"
            container: containerName
            device: deviceName
            type: 'proxy'
            properties: configProxy
        # Start container
        await @lxc.start
          $header: 'Start'
          container: containerName        
        # Wait until container is ready
        await @lxc.wait.ready 
          $header: 'Wait for container to be ready to use'
          container: containerName
          nat: true 
        # Openssl is required by the `lxc.file.push` action
        await @lxc.exec
          $header: 'OpenSSL'
          container: containerName
          command: """
          command -v openssl && exit 42
          if command -v yum >/dev/null 2>&1; then
            yum -y install openssl
          elif command -v apt-get >/dev/null 2>&1; then
            apt-get -y install openssl
          elif command -v apk >/dev/null 2>&1; then
            apk add openssl
          else
            echo "Unsupported Package Manager" >&2 && exit 2
          fi
          command -v openssl
          """
          trap: true
          code: [0, 42]
        # Enable SSH
        if containerConfig.ssh?.enabled
          await @lxc.exec
            $header: 'SSH'
            container: containerName
            command: """
            if command -v systemctl >/dev/null 2>&1; then
              systemctl status sshd && exit 42 || echo '' > /dev/null
            elif command -v rc-service >/dev/null 2>&1; then
              # Exit code 3 if stopped
              rc-service sshd status && exit 42 || echo '' > /dev/null
            fi
            if command -v yum >/dev/null 2>&1; then
              yum -y install openssh-server
            elif command -v apt-get >/dev/null 2>&1; then
              apt-get -y install openssh-server
            elif command -v apk >/dev/null 2>&1; then
              apk add openssh-server
            else
              echo "Unsupported package manager" >&2 && exit 2
            fi
            if command -v systemctl >/dev/null 2>&1; then
              # systemctl status sshd && exit 42
              systemctl start sshd
              systemctl enable sshd
            elif command -v rc-update >/dev/null 2>&1; then
              rc-service sshd start
              rc-update add sshd
            else
              echo "Unsupported init system" >&2 && exit 3
            fi
            """
            trap: true
            code: [0, 42]
        # Create users
        for userName, configUser of containerConfig.user then await @call
          $header: "User #{userName}"
        , ->
          await @lxc.exec
            $header: 'Create'
            container: containerName
            command: """
            id #{userName} && exit 42
            useradd --create-home --system #{userName}
            mkdir -p /home/#{userName}/.ssh
            chown #{userName}.#{userName} /home/#{userName}/.ssh
            chmod 700 /home/#{userName}/.ssh
            """
            trap: true
            code: [0, 42]
          # Enable sudo access
          await @lxc.exec
            $if: configUser.sudo
            $header: 'Sudo'
            container: containerName
            command: """
            yum install -y sudo
            command -v sudo
            cat /etc/sudoers | grep "#{userName}" && exit 42
            echo "#{userName} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
            """
            trap: true
            code: [0, 42]
          # Add SSH public key to authorized_keys file
          await @lxc.file.push
            $if: configUser.authorized_keys
            $header: 'Authorize'
            container: containerName
            gid: "#{userName}"
            uid: "#{userName}"
            mode: 600
            source: "#{configUser.authorized_keys}"
            target: "/home/#{userName}/.ssh/authorized_keys"
      # Provision containers
      if !!config.provision_container
        for containerName, containerConfig of config.containers
          await @call
            container: containerName
          , containerConfig
          , config.provision_container
      # Provision
      if !!config.provision
        await @call config, config.provision

## Exports

    module.exports =
      handler: handler
      hooks:
        on_action: on_action
      metadata:
        definitions: definitions

## Dependencies

    utils = require '../utils'
