// Dependencies
const dedent = require('dedent');
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    log({
      message: `Status for service ${config.name}`,
      level: "INFO",
    });
    try {
      const { $status } = await this.execute({
        command: dedent`
          ls /lib/systemd/system/*.service /etc/systemd/system/*.service /etc/rc.d/* /etc/init.d/* 2>/dev/null | grep -w "${config.name}" || exit 3
          if command -v systemctl >/dev/null 2>&1; then
            systemctl status ${config.name} || exit 3
          elif command -v service >/dev/null 2>&1; then
            service ${config.name} status || exit 3
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
        `,
        code: [0, 3],
      });
      log({
        message: `Status for ${config.name} is ${
          $status ? "started" : "stoped"
        }`,
        level: "INFO",
      });
    } catch (error) {
      if (error.exit_code === 2) {
        throw Error("Unsupported Loader");
      }
      throw error;
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
