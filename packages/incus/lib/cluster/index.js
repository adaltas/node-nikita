// Dependencies
import dedent from "dedent";
import utils from "@nikitajs/incus/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    if (config.prevision) {
      await this.call(config, config.prevision);
    }
    // Create a network
    for (const name in config.networks) {
      const networkProperties = config.networks[name];
      await this.incus.network({
        $header: `Network ${name}`,
        name: name,
        properties: networkProperties,
      });
    }
    if (config.prevision_container) {
      for (const name in config.containers) {
        const container = config.containers[name];
        await this.call(
          {
            name: name,
          },
          container,
          config.prevision_container,
        );
      }
    }
    // Init containers
    for (const name in config.containers) {
      const container = config.containers[name];
      await this.call(
        {
          $header: `Container ${name}`,
        },
        async function () {
          // Set configuration
          await this.incus.init({
            $header: "Init",
            ...utils.object.filter(container, [
              "disk",
              "nic",
              "properties",
              "proxy",
              "user",
              "ssh",
            ]),
          });
          // Set config
          if (container.properties) {
            await this.incus.config.set({
              $header: "Properties",
              name: name,
              properties: container.properties,
            });
          }
          // Create disk device
          for (const deviceName in container.disk) {
            await this.incus.config.device({
              $header: `Device ${deviceName} disk`,
              name: name,
              device: deviceName,
              type: "disk",
              properties: container.disk[deviceName],
            });
          }
          // Create nic device
          for (const deviceName in container.nic) {
            const configNic = container.nic[deviceName];
            // note: `confignic.config.parent` is not required for each type
            // throw Error "Required Property: nic.#{device}.parent" unless confignic.config.parent
            await this.incus.config.device({
              $header: `Device ${deviceName} nic`,
              name: name,
              device: deviceName,
              type: "nic",
              properties: utils.object.filter(configNic, ["ip", "netmask"]),
            });
          }
          // Create proxy device
          for (const deviceName in container.proxy) {
            const configProxy = container.proxy[deviceName];
            // todo: add host detection and port forwarding to VirtualBox
            // VBoxManage controlvm 'incus' natpf1 'ipa_ui,tcp,0.0.0.0,2443,,2443'
            await this.incus.config.device({
              $header: `Device ${name} proxy`,
              name: name,
              device: deviceName,
              type: "proxy",
              properties: configProxy,
            });
          }
          // Start container
          await this.incus.start({
            $header: "Start",
            name: name,
          });
          // Wait until container is ready
          await this.incus.wait.ready({
            $header: "Wait for container to be ready to use",
            name: name,
            nat: true,
            nat_check: process.env.CI ? "wget -q google.com" : undefined,
          });
          // Openssl is required by the `incus.file.push` action
          await this.incus.exec({
            $header: "OpenSSL",
            name: name,
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
            code: [0, 42],
          });
          // Enable SSH
          if (container.ssh?.enabled) {
            await this.incus.exec({
              $header: "SSH",
              name: name,
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
              code: [0, 42],
            });
          }
          // Create users
          for (const userName in container.user) {
            const configUser = container.user[userName];
            await this.call(
              {
                $header: `User ${userName}`,
              },
              async function () {
                await this.incus.exec({
                  $header: "Create",
                  name: name,
                  command: dedent`
                    id ${userName} && exit 42
                    useradd --create-home --system ${userName}
                    mkdir -p /home/${userName}/.ssh
                    chown ${userName}.${userName} /home/${userName}/.ssh
                    chmod 700 /home/${userName}/.ssh
                  `,
                  trap: true,
                  code: [0, 42],
                });
                // Enable sudo access
                await this.incus.exec({
                  $if: configUser.sudo,
                  $header: "Sudo",
                  name: name,
                  command: dedent`
                    yum install -y sudo
                    command -v sudo
                    cat /etc/sudoers | grep "${userName}" && exit 42
                    echo "${userName} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
                  `,
                  trap: true,
                  code: [0, 42],
                });
                // Add SSH public key to authorized_keys file
                await this.incus.file.push({
                  $if: configUser.authorized_keys,
                  $header: "Authorize",
                  name: name,
                  gid: `${userName}`,
                  uid: `${userName}`,
                  mode: 600,
                  source: `${configUser.authorized_keys}`,
                  target: `/home/${userName}/.ssh/authorized_keys`,
                });
              },
            );
          }
        },
      );
    }
    if (config.provision_container) {
      for (const name in config.containers) {
        const container = config.containers[name];
        await this.call(
          {
            name: name,
          },
          container,
          config.provision_container,
        );
      }
    }
    if (config.provision) {
      await this.call(config, config.provision);
    }
  },
  hooks: {
    on_action: {
      before: ["@nikitajs/core/src/plugins/metadata/schema"],
      handler: function ({ config }) {
        for (const name in config.containers) {
          config.containers[name].name = name;
        }
      },
    },
  },
  metadata: {
    definitions: definitions,
  },
};
