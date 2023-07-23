// Dependencies
const dedent = require('dedent');
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    log({
      message: `Startup service ${config.name}`,
      level: "INFO",
    });
    if (!config.command) {
      const { stdout } = await this.execute({
        $shy: true,
        command: dedent`
          if command -v systemctl >/dev/null 2>&1; then
            echo 'systemctl'
          elif command -v chkconfig >/dev/null 2>&1; then
            echo 'chkconfig'
          elif command -v update-rc.d >/dev/null 2>&1; then
            echo 'update-rc'
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
        `,
      });
      config.command = stdout.trim();
      if (
        config.command !== "systemctl" &&
        config.command !== "chkconfig" &&
        config.command !== "update-rc"
      ) {
        throw Error("Unsupported Loader");
      }
    }
    switch (config.command) {
      case "systemctl": // systemd
        try {
          const { $status } = await this.execute({
            command: `
              startup=${config.startup ? "1" : ""}
              if systemctl is-enabled ${config.name}; then
                [ -z "$startup" ] || exit 3
                echo 'Disable ${config.name}'
                systemctl disable ${config.name}
              else
                [ -z "$startup" ] && exit 3
                echo 'Enable ${config.name}'
                systemctl enable ${config.name}
              fi
            `,
            trap: true,
            code: [0, 3],
          });
          // arch_chroot: config.arch_chroot
          // arch_chroot_rootdir: config.arch_chroot_rootdir
          const message = config.startup ? "activated" : "disabled";
          return log(
            $status
              ? {
                  message: `Service startup updated: ${message}`,
                  level: "WARN",
                }
              : {
                  message: `Service startup not modified: ${message}`,
                  level: "INFO",
                }
          );
        } catch {
          if (config.startup) {
            throw Error(`Startup Enable Failed: ${config.name}`);
          }
          if (!config.startup) {
            throw Error(`Startup Disable Failed: ${config.name}`);
          }
        }
        break;
      case "chkconfig":
        try {
          const { $status, stdout, stderr } = await this.execute({
            $shy: true,
            command: `chkconfig --list ${config.name}`,
            code: [0, 1],
          });
          // Invalid service name return code is 0 and message in stderr start by error
          if (/^error/.test(stderr)) {
            log({
              message: `Invalid chkconfig name for \"${config.name}\"`,
              level: "ERROR",
            });
            throw Error(`Invalid chkconfig name for \`${config.name}\``);
          }
          let current_startup = "";
          if ($status) {
            for (const c of stdout.split(" ").pop().trim().split("\t")) {
              const [level, status] = c.split(":");
              if (["on", "marche"].indexOf(status) > -1) {
                current_startup += level;
              }
            }
          }
          if (config.startup === true && current_startup.length) {
            return;
          }
          if (config.startup === current_startup) {
            return;
          }
          if ($status && config.startup === false && current_startup === "") {
            return;
          }
          if (config.startup) {
            let command = `chkconfig --add ${config.name};`;
            if (typeof config.startup === "string") {
              let startup_on = startup_off = "";
              for (i = k = 0; k < 6; i = ++k) {
                if (config.startup.indexOf(i) !== -1) {
                  startup_on += i;
                } else {
                  startup_off += i;
                }
              }
              if (startup_on) {
                command += `chkconfig --level ${startup_on} ${config.name} on;`;
              }
              if (startup_off) {
                command += `chkconfig --level ${startup_off} ${config.name} off;`;
              }
            } else {
              command += `chkconfig ${config.name} on;`;
            }
            await this.execute({
              command: command,
            });
          }
          if (!config.startup) {
            log({
              message: "Desactivating startup rules",
              level: "DEBUG",
            });
            // Setting the level to off. An alternative is to delete it: `chkconfig --del #{config.name}`
            await this.execute({
              command: `chkconfig ${config.name} off`,
            });
          }
          const message = config.startup ? "activated" : "disabled";
          return log(
            $status
              ? {
                  message: `Service startup updated: ${message}`,
                  level: "WARN",
                }
              : {
                  message: `Service startup not modified: ${message}`,
                  level: "INFO",
                }
          );
        } catch (error) {
          throw error
        }
      case "update-rc": // System-V
        const { $status } = await this.execute({
          command: dedent`
            startup=${config.startup ? "1" : ""}
            if ls /etc/rc*.d/S??${config.name}; then
              [ -z "$startup" ] || exit 3
              echo 'Disable ${config.name}'
              update-rc.d -f ${config.name} disable
            else
              [ -z "$startup" ] && exit 3
              echo 'Enable ${config.name}'
              update-rc.d -f ${config.name} enable
            fi
          `,
          code: [0, 3],
        });
        // arch_chroot: config.arch_chroot
        // arch_chroot_rootdir: config.arch_chroot_rootdir
        const message = config.startup ? "activated" : "disabled";
        log(
          $status
            ? {
                message: `Service startup updated: ${message}`,
                level: "WARN",
              }
            : {
                message: `Service startup not modified: ${message}`,
                level: "INFO",
              }
        );
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
