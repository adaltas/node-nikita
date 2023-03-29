// Dependencies
const dedent = require('dedent');
const utils = require('../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    if (!!config.prevision) {
      await this.call(config, config.prevision);
    }
    // Create a network
    for (const networkName in config.networks) {
      const networkProperties = config.networks[networkName];
      await this.lxc.network({
        $header: `Network ${networkName}`,
        network: networkName,
        properties: networkProperties
      });
    }
    if (!!config.prevision_container) {
      for (const containerName in config.containers) {
        const containerConfig = config.containers[containerName];
        await this.call({
          container: containerName
        }, containerConfig, config.prevision_container);
      }
    }
    // Init containers
    for (const containerName in config.containers) {
      const containerConfig = config.containers[containerName];
      await this.call({
        $header: `Container ${containerName}`
      }, async function() {
        // Set configuration
        await this.lxc.init({
          $header: 'Init'
        }, containerConfig);
        // Set config
        if (containerConfig != null ? containerConfig.properties : void 0) {
          await this.lxc.config.set({
            $header: 'Properties',
            container: containerName,
            properties: containerConfig.properties
          });
        }
        // Create disk device
        for (const deviceName in containerConfig.disk) {
          const configDisk = containerConfig.disk[deviceName];
          await this.lxc.config.device({
            $header: `Device ${deviceName} disk`,
            container: containerName,
            device: deviceName,
            type: 'disk',
            properties: configDisk
          });
        }
        // Create nic device
        for (const deviceName in containerConfig.nic) {
          const configNic = containerConfig.nic[deviceName];
          // note: `confignic.config.parent` is not required for each type
          // throw Error "Required Property: nic.#{device}.parent" unless confignic.config.parent
          await this.lxc.config.device({
            $header: `Device ${deviceName} nic`,
            container: containerName,
            device: deviceName,
            type: 'nic',
            properties: utils.object.filter(configNic, ['ip', 'netmask'])
          });
        }
        // Create proxy device
        for (const deviceName in containerConfig.proxy) {
          const configProxy = containerConfig.proxy[deviceName];
          // todo: add host detection and port forwarding to VirtualBox
          // VBoxManage controlvm 'lxd' natpf1 'ipa_ui,tcp,0.0.0.0,2443,,2443'
          await this.lxc.config.device({
            $header: `Device ${deviceName} proxy`,
            container: containerName,
            device: deviceName,
            type: 'proxy',
            properties: configProxy
          });
        }
        // Start container
        await this.lxc.start({
          $header: 'Start',
          container: containerName
        });
        
        // Wait until container is ready
        await this.lxc.wait.ready({
          $header: 'Wait for container to be ready to use',
          container: containerName,
          nat: true,
          nat_check: !!process.env.CI ? 'wget -q google.com' : void 0
        });
        // Openssl is required by the `lxc.file.push` action
        await this.lxc.exec({
          $header: 'OpenSSL',
          container: containerName,
          command: dedent`
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
          `,
          trap: true,
          code: [0, 42]
        });
        // Enable SSH
        if (containerConfig.ssh?.enabled) {
          await this.lxc.exec({
            $header: 'SSH',
            container: containerName,
            command: dedent`
              if command -v systemctl >/dev/null 2>&1; then
                srv=\`systemctl list-units --all --type=service | grep ssh | sed 's/ *\\(ssh.*\\)\.service.*/\\1/'\`
                [ ! -z $srv ] && systemctl status $srv && exit 42 || echo '' > /dev/null
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
                # Support \`ssh\` and \`sshd\`: changed between 16.04 and 22.04
                # systemctl list-units not showing sshd on centos 7 if module not started, fixing with --all
                srv=\`systemctl list-units --all --type=service | grep ssh | sed 's/ *\\(ssh.*\\)\.service.*/\\1/'\`
                systemctl start $srv
                systemctl enable $srv
              elif command -v rc-update >/dev/null 2>&1; then
                rc-service sshd start
                rc-update add sshd
              else
                echo "Unsupported init system" >&2 && exit 3
              fi
            `,
            trap: true,
            code: [0, 42]
          });
        }
        // Create users
        for (const userName in containerConfig.user) {
          const configUser = containerConfig.user[userName];
          await this.call({
            $header: `User ${userName}`
          }, async function() {
            await this.lxc.exec({
              $header: 'Create',
              container: containerName,
              command: dedent`
                id ${userName} && exit 42
                useradd --create-home --system ${userName}
                mkdir -p /home/${userName}/.ssh
                chown ${userName}.${userName} /home/${userName}/.ssh
                chmod 700 /home/${userName}/.ssh
              `,
              trap: true,
              code: [0, 42]
            });
            // Enable sudo access
            await this.lxc.exec({
              $if: configUser.sudo,
              $header: 'Sudo',
              container: containerName,
              command: dedent`
                yum install -y sudo
                command -v sudo
                cat /etc/sudoers | grep "${userName}" && exit 42
                echo "${userName} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
              `,
              trap: true,
              code: [0, 42]
            });
            // Add SSH public key to authorized_keys file
            await this.lxc.file.push({
              $if: configUser.authorized_keys,
              $header: 'Authorize',
              container: containerName,
              gid: `${userName}`,
              uid: `${userName}`,
              mode: 600,
              source: `${configUser.authorized_keys}`,
              target: `/home/${userName}/.ssh/authorized_keys`
            });
          });
        }
      });
    }
    if (!!config.provision_container) {
      for (const containerName in config.containers) {
        const containerConfig = config.containers[containerName];
        await this.call({
          container: containerName
        }, containerConfig, config.provision_container);
      }
    }
    if (!!config.provision) {
      await this.call(config, config.provision);
    }
  },
  hooks: {
    on_action: {
      before: ['@nikitajs/core/src/plugins/metadata/schema'],
      handler: function({config}) {
        for (const name in config.containers) {
          config.containers[name].container = name;
        }
      }
    }
  },
  metadata: {
    definitions: definitions
  }
};
