// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config, parent: { state }, tools: { log } }) {
    log({
      message: `Restart service ${config.name}`,
      level: "INFO",
    });
    const { loader } = await this.service.discover({});
    if (config.loader == null) {
      config.loader = loader;
    }
    const { status } = await this.execute({
      command: (function () {
        switch (config.loader) {
          case "systemctl":
            return `systemctl restart ${config.name}`;
          case "service":
            return `service ${config.name} restart`;
          default:
            throw Error("Init System not supported");
        }
      })(),
    });
    if (status) {
      state[`nikita.service.${config.name}.status`] = "started";
    }
    return {
      status: status,
    };
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
