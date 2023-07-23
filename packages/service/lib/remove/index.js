// Dependencies
const dedent = require('dedent');
const utils = require('@nikitajs/core/lib/utils');
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config, parent: { state }, tools: { log } }) {
    log({
      message: `Remove service ${config.name}`,
      level: "INFO",
    });
    const cacheonly = config.cacheonly ? "-C" : "";
    let installed = config.cache ? state["nikita:execute:installed"] : null;
    if (installed === null) {
      try {
        const { stdout } = await this.execute({
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
          stdout_log: false,
        });
        log({
          message: "Installed packages retrieved",
          level: "INFO",
        });
        installed = utils.string.lines(stdout);
      } catch (error) {
        if (error.exit_code === 2) {
          throw Error("Unsupported Package Manager");
        }
        throw error;
      }
    }
    if (installed.includes(config.name)) {
      try {
        const { $status } = await this.execute({
          command: `
            if command -v yum >/dev/null 2>&1; then
              yum remove -y ${cacheonly} '${config.name}'
            elif command -v pacman >/dev/null 2>&1; then
              pacman --noconfirm -R ${config.name}
            elif command -v apt-get >/dev/null 2>&1; then
              apt-get remove -y ${config.name}
            else
              echo "Unsupported Package Manager: yum, pacman, apt-get supported" >&2
              exit 2
            fi
          `,
          code: [0, 3],
        });
        // Update list of installed packages
        installed.splice(installed.indexOf(config.name), 1);
        // Log information
        log(
          $status
            ? {
                message: "Service removed",
                level: "WARN",
              }
            : {
                message: "Service already removed",
                level: "INFO",
              }
        );
      } catch (error) {
        throw Error(`Invalid Service Name: ${config.name}`);
      }
    }
    if (config.cache) {
      log({
        message: 'Caching installed on "nikita:execute:installed"',
        level: "INFO",
      });
      state["nikita:execute:installed"] = installed;
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
