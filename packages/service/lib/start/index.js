// Dependencies
const dedent = require('dedent');
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    try {
      const { $status } = await this.execute({
        command: dedent`
          ls /lib/systemd/system/*.service /etc/systemd/system/*.service /etc/rc.d/* /etc/init.d/* 2>/dev/null | grep -w "${config.name}" || exit 3
          if command -v systemctl >/dev/null 2>&1; then
            systemctl status ${config.name} && exit 3
            systemctl start ${config.name}
          elif command -v service >/dev/null 2>&1; then
            service ${config.name} status && exit 3
            service ${config.name} start
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
        `,
        code: [0, 3],
      });
      if ($status) {
        // arch_chroot: config.arch_chroot
        // rootdir: config.rootdir
        log({
          message: "Service is started",
          level: "INFO",
        });
      }
      if (!$status) {
        return log({
          message: "Service already started",
          level: "WARN",
        });
      }
    } catch (error) {
      if (error.exit_code === 2) {
        throw Error("Unsupported Loader");
      }
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
