// Dependencies
import dedent from "dedent";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { $status } = await this.call(
      {
        $retry: 100,
        $sleep: 1000,
      },
      async function () {
        const {
          state: { processes },
        } = await this.incus.state({
          $header: "Checking if instance is ready",
          name: config.name,
        });
        // Processes are at -1 when they aren't ready
        if (processes < 0) {
          throw Error("Reschedule: Instance not booted");
        }
        // Sometimes processes alone aren't enough, so we test if we can get the container
        const { $status } = await this.incus.exec({
          $header: "Trying to execute a command",
          name: config.name,
          command: dedent`
          if ( command -v systemctl || command -v rc-service ); then
            exit 0
          else
            exit 42
          fi
        `,
          code: [0, 42],
        });
        if ($status === false) {
          throw Error("Reschedule: Instance not ready to execute commands");
        }
        // Checking if internet is working and ready for us to use
        if (config.nat === true) {
          const { $status } = await this.incus.exec({
            $header: "Trying to connect to internet",
            name: config.name,
            command: config.nat_check,
            code: [0, 42],
          });
          if ($status === false) {
            throw Error("Reschedule: Internet not ready");
          }
        }
      },
    );
    return {
      $status: $status,
    };
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
