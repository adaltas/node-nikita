// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    log("INFO", `Status for service ${config.name}`);
    const { $status: started } = await this.execute({
      $shy: true,
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
    }).catch(error => {
      if (error.exit_code === 2) {
        throw Error("Unsupported Loader");
      }
      throw error;
    });
    log(
      "INFO",
      `Service ${config.name} is ${started ? "started" : "stoped"}.`
    );
    return {
      started: started
    }
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
