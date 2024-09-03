// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { $status: exists, data: running } = await this.docker.tools.execute({
      $templated: false,
      command: `inspect ${config.container} --format '{{ json .State.Running }}'`,
      code: [0, 1],
      format: "json",
    });
    if (!exists) {
      return false;
    }
    if (running && !config.force) {
      throw Error("Container must be stopped to be removed without force");
    }
    await this.docker.tools.execute({
      command: [
        "rm",
        ...["link", "volumes", "force"]
          .filter(function (opt) {
            return config[opt];
          })
          .map(function (opt) {
            return `-${opt.charAt(0)}`;
          }),
        config.container,
      ].join(" "),
    });
  },
  metadata: {
    argument_to_config: "container",
    global: "docker",
    definitions: definitions,
  },
};
