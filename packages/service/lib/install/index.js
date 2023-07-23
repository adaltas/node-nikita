// Dependencies
const dedent = require('dedent');
const utils = require('@nikitajs/core/lib/utils');
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config, parent: { state }, tools: { log } }) {
    if (config.cache) {
      // Config
      if (config.installed == null) {
        config.installed = state["nikita:execute:installed"];
      }
    }
    if (config.cache) {
      if (config.outdated == null) {
        config.outdated = state["nikita:execute:outdated"];
      }
    }
    const cacheonly = config.cacheonly ? "-C" : "";
    for (const i in config.pacman_flags) {
      const flag = config.pacman_flags[i];
      if (/^-/.test(flag)) {
        continue;
      }
      if (flag.length === 1) {
        config.pacman_flags[i] = `-${flag}`;
      }
      if (flag.length > 1) {
        config.pacman_flags[i] = `--${flag}`;
      }
    }
    for (const i in config.yay_flags) {
      const flag = config.yay_flags[i];
      if (/^-/.test(flag)) {
        continue;
      }
      if (flag.length === 1) {
        config.yay_flags[i] = `-${flag}`;
      }
      if (flag.length > 1) {
        config.yay_flags[i] = `--${flag}`;
      }
    }
    // Start real work
    log({
      message: `Install service ${config.name}`,
      level: "INFO",
    });
    // List installed packages
    if (config.installed == null) {
      try {
        const { $status, stdout } = await this.execute({
          $shy: true,
          command: dedent`
            if command -v yum >/dev/null 2>&1; then
              rpm -qa --qf "%{NAME}\n"
            elif command -v pacman >/dev/null 2>&1; then
              pacman -Qqe
            elif command -v apt-get >/dev/null 2>&1; then
              dpkg -l | grep \'^ii\' | awk \'{print $2}\'
            else
              echo "Unsupported Package Manager" >&2
              exit 2
            fi
          `,
          code: [0, 1],
          stdin_log: false,
          stdout_log: false,
        });
        if ($status) {
          log({
            message: "Installed packages retrieved",
            level: "INFO",
          });
          config.installed = utils.string.lines(stdout)
        }
      } catch (error) {
        if (error.exit_code === 2) {
          throw Error("Unsupported Package Manager");
        }
        throw error
      }
    }
    // List packages waiting for update
    if (config.outdated == null) {
      try {
        const { $status, stdout } = await this.execute({
          $shy: true,
          command: `
            if command -v yum >/dev/null 2>&1; then
              yum ${cacheonly} check-update -q | sed 's/\\([^\\.]*\\).*/\\1/'
            elif command -v pacman >/dev/null 2>&1; then
              pacman -Qu | sed 's/\\([^ ]*\\).*/\\1/'
            elif command -v apt-get >/dev/null 2>&1; then
              apt-get -u upgrade --assume-no | grep '^\\s' | sed 's/\\s/\\n/g'
            else
              echo "Unsupported Package Manager" >&2
              exit 2
            fi
          `,
          code: [0, 1],
          stdin_log: false,
          stdout_log: false,
        });
        if ($status) {
          log({
            message: "Outdated package list retrieved",
            level: "INFO",
          });
          config.outdated = utils.string.lines(stdout.trim());
        } else {
          config.outdated = [];
        }
      } catch (error) {
        if (error.exit_code === 2) {
          throw Error("Unsupported Package Manager");
        }
        throw error;
      }
    }
    // Install the package
    if (!config.installed.includes(config.name) || config.outdated.includes(config.name)) {
      try {
        const { $status } = await this.execute({
          command: dedent`
            if command -v yum >/dev/null 2>&1; then
              yum install -y ${cacheonly} ${config.name}
            elif command -v yay >/dev/null 2>&1; then
              yay --noconfirm -S ${config.name} ${config.yay_flags.join(" ")}
            elif command -v pacman >/dev/null 2>&1; then
              pacman --noconfirm -S ${config.name} ${config.pacman_flags.join(" ")}
            elif command -v apt-get >/dev/null 2>&1; then
              env DEBIAN_FRONTEND=noninteractive apt-get install -y ${config.name}
            else
              echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
              exit 2
            fi
          `,
          code: config.code,
        });
        log(
          $status
            ? {
                message: `Package \"${config.name}\" is installed`,
                level: "WARN",
              }
            : {
                message: `Package \"${config.name}\" is already installed`,
                level: "INFO",
              }
        );
        // Enrich installed array with package name unless already there
        if (config.installed.includes(config.name)) {
          config.installed.push(config.name);
        }
        // Remove package name from outdated if listed
        if (config.outdated) {
          const outdatedIndex = config.outdated.indexOf(config.name);
          if (outdatedIndex !== -1) {
            config.outdated.splice(outdatedIndex, 1);
          }
        }
      } catch (error) {
        if (error.exit_code === 2) {
          throw Error(
            "Unsupported Package Manager: apt-get, pacman, yay, yum supported"
          );
        }
        throw utils.error(
          "NIKITA_SERVICE_INSTALL",
          ["failed to install package,", `name is \`${config.name}\``],
          {
            target: config.target,
          }
        );
      }
    }
    if (config.cache) {
      log({
        message: 'Caching installed on "nikita:execute:installed"',
        level: "INFO",
      });
      state["nikita:execute:installed"] = config.installed;
      log({
        message: 'Caching outdated list on "nikita:execute:outdated"',
        level: "INFO",
      });
      state["nikita:execute:outdated"] = config.outdated;
      return {
        $status: true,
      };
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
