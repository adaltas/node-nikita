// Dependencies
import fs from "node:fs/promises";
import dedent from "dedent";
import connect from "ssh2-connect";
import exec from "ssh2-exec";
import utils from "@nikitajs/core/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ metadata, config, tools: { log } }) {
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
      config.selinux = "permissive";
    }
    if (
      config.selinux &&
      config.selinux !== "enforcing" &&
      config.selinux !== "permissive" &&
      config.selinux !== "disabled"
    ) {
      // Validation
      throw Error(`Invalid option \"selinux\": ${config.selinux}`);
    }
    let rebooting = false;
    // Read public key if option is a path
    if (config.public_key_path && !config.public_key) {
      const location = await utils.tilde.normalize(config.public_key_path);
      try {
        ({ data: config.public_key } = await fs.readFile(location, "ascii"));
      } catch (error) {
        if (error.code === "ENOENT") {
          throw Error(`Private key doesnt exists: ${JSON.stringify(location)}`);
        }
        throw error;
      }
    }
    // Read private key if option is a path
    if (config.private_key_path && !config.private_key) {
      log({
        message: `Read Private Key: ${JSON.stringify(config.private_key_path)}`,
        level: "DEBUG",
      });
      const location = await utils.tilde.normalize(config.private_key_path);
      try {
        ({ data: config.private_key } = await fs.readFile(location, "ascii"));
      } catch (error) {
        if (error.code === "ENOENT") {
          throw Error(`Private key doesnt exists: ${JSON.stringify(location)}`);
        }
        throw error;
      }
    }
    await this.call(async function () {
      log("DEBUG", "Opening connection");
      const conn = !metadata.dry ? await connect(config) : null;
      log("INFO", "Connection establish");
      let command = [];
      command.push(
        `sed -i.back 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config;`
      );
      if (config.public_key) {
        command.push(dedent`
          mkdir -p /root/.ssh; chmod 700 /root/.ssh;
          echo '${config.public_key}' >> /root/.ssh/authorized_keys;
        `);
      }
      command.push(dedent`
        sed -i.back 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config;
        selinux="${config.selinux || ""}";
        if [ -n "$selinux" ] && [ -f /etc/selinux/config ] && grep ^SELINUX="$selinux" /etc/selinux/config;
        then
          sed -i.back "s/^SELINUX=enforcing/SELINUX=$selinux/" /etc/selinux/config;
          ( reboot )&
          exit 2;
        fi;
      `);
      command = command.join("\n");
      if (config.username !== "root") {
        command = command.replace(/\n/g, " ");
        if (typeof config.command === "function") {
          command = config.command(command);
        } else if (typeof config.command === "string") {
          command = `${config.command} ${command}`;
        } else {
          config.command = "sudo ";
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
        level: "DEBUG",
      });
      log({
        message: command,
        type: "stdin",
      });
      if (!metadata.dry) {
        const child = exec(
          {
            ssh: conn,
            command: command,
          },
          (error) => {
            if (error?.code === 2) {
              log("WARN", "Root Access Enabled");
              rebooting = true;
            } else {
              throw error;
            }
          }
        );
        child.stdout.on("data", (data) =>
          log({ message: data, type: "stdout" })
        );
        child.stdout.on("end", () =>
          log({ message: null, type: "stdout" })
        );
        child.stderr.on("data", (data) =>
          log({ message: data, type: "stderr" })
        );
        child.stderr.on("end", () =>
          log({ message: null, type: "stderr" })
        );
      }
    });
    await this.call(
      {
        $if: rebooting,
        $retry: true,
        $sleep: 3000,
      },
      async function () {
        (await connect(config)).end();
      }
    );
  },
  metadata: {
    definitions: definitions,
  },
};
