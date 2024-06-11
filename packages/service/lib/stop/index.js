// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    log({
      message: `Stop service ${config.name}`,
      level: "INFO",
    });
    try {
      const { $status } = await this.execute({
        command: dedent`
          ls /lib/systemd/system/*.service /etc/systemd/system/*.service /etc/rc.d/* /etc/init.d/* 2>/dev/null | grep -w "${config.name}" || exit 3
          if command -v systemctl >/dev/null 2>&1; then
            systemctl status ${config.name} || exit 3
            systemctl stop ${config.name}
          elif command -v service >/dev/null 2>&1; then
            service ${config.name} status || exit 3
            service ${config.name} stop
          else
            echo "Unsupported Loader" >&2
            exit 2
          fi
        `,
        code: [0, 3],
      });
      if ($status) {
        log({
          message: "Service is stopped",
          level: "INFO",
        });
      }
      if (!$status) {
        log({
          message: "Service already stopped",
          level: "WARN",
        });
      }
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
