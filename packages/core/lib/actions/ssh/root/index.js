// Dependencies
const fs = require('fs/promises');
const dedent = require('dedent');
const connect = require('ssh2-connect');
const exec = require('ssh2-exec');
const utils = require('../../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({metadata, config, tools: {log}}) {
    var err, ref;
    if (config.host == null) {
      config.host = config.ip;
    }
    // config.command ?= 'su -'
    if (config.username == null) {
      config.username = null;
    }
    if (config.password == null) {
      config.password = null;
    }
    if (config.selinux == null) {
      config.selinux = false;
    }
    if (config.selinux === true) {
      config.selinux = 'permissive';
    }
    if (config.selinux && ((ref = config.selinux) !== 'enforcing' && ref !== 'permissive' && ref !== 'disabled')) {
      // Validation
      throw Error(`Invalid option \"selinux\": ${config.selinux}`);
    }
    let rebooting = false;
    // Read public key if option is a path
    if (config.public_key_path && !config.public_key) {
      const location = await utils.tilde.normalize(config.public_key_path);
      try {
        ({
          data: config.public_key
        } = (await fs.readFile(location, 'ascii')));
      } catch (error) {
        err = error;
        if (err.code === 'ENOENT') {
          throw Error(`Private key doesnt exists: ${JSON.stringify(location)}`);
        }
        throw err;
      }
    }
    // Read private key if option is a path
    if (config.private_key_path && !config.private_key) {
      log({
        message: `Read Private Key: ${JSON.stringify(config.private_key_path)}`,
        level: 'DEBUG'
      });
      const location = await utils.tilde.normalize(config.private_key_path);
      try {
        ({
          data: config.private_key
        } = (await fs.readFile(location, 'ascii')));
      } catch (error) {
        err = error;
        if (err.code === 'ENOENT') {
          throw Error(`Private key doesnt exists: ${JSON.stringify(location)}`);
        }
        throw err;
      }
    }
    await this.call(async function() {
      log({
        message: "Connecting",
        level: 'DEBUG'
      });
      const conn = !metadata.dry ? (await connect(config)) : null;
      log({
        message: "Connected",
        level: 'INFO'
      });
      let command = [];
      command.push(`sed -i.back 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config;`);
      if (config.public_key) {
        command.push(dedent`
          mkdir -p /root/.ssh; chmod 700 /root/.ssh;
          echo '${config.public_key}' >> /root/.ssh/authorized_keys;
        `);
      }
      command.push(dedent`
        sed -i.back 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config;
        selinux="${config.selinux || ''}";
        if [ -n "$selinux" ] && [ -f /etc/selinux/config ] && grep ^SELINUX="$selinux" /etc/selinux/config;
        then
          sed -i.back "s/^SELINUX=enforcing/SELINUX=$selinux/" /etc/selinux/config;
          ( reboot )&
          exit 2;
        fi;
      `);
      command = command.join('\n');
      if (config.username !== 'root') {
        command = command.replace(/\n/g, ' ');
        if (typeof config.command === 'function') {
          command = config.command(command);
        } else if (typeof config.command === 'string') {
          command = `${config.command} ${command}`;
        } else {
          config.command = 'sudo ';
          if (config.user) {
            config.command += `-u ${config.user} `;
          }
          if (config.password) {
            config.command = `echo -e \"${config.password}\\n\" | ${config.command} -S `;
          }
          config.command += `-- sh -c \"${command}\"`;
          command = config.command;
        }
      }
      log({
        message: "Enable Root Access",
        level: 'DEBUG'
      });
      log({
        message: command,
        type: 'stdin'
      });
      if (!metadata.dry) {
        const child = exec({
          ssh: conn,
          command: command
        }, (error) => {
          if (error?.code === 2) {
            log({
              message: "Root Access Enabled",
              level: "WARN",
            });
            rebooting = true;
          } else {
            throw error;
          }
        });
        child.stdout.on("data", (data) =>
          log({ message: data, type: "stdout" })
        );
        child.stdout.on("end", (data) =>
          log({ message: null, type: "stdout" })
        );
        child.stderr.on("data", (data) =>
          log({ message: data, type: "stderr" })
        );
        child.stderr.on("end", (data) =>
          log({ message: null, type: "stderr" })
        );
      }
    });
    await this.call({
      $if: rebooting,
      $retry: true,
      $sleep: 3000
    }, async function() {
      (await connect(config)).end();
    });
  },
  metadata: {
    definitions: definitions
  }
};
