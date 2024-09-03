// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    if (config.pre_stop) {
      await this.call(config, config.pre_stop);
    }
    // Stop containers
    for (const containerName in config.containers) {
      await this.incus.stop({
        $header: `Container ${containerName} : stop`,
        container: containerName,
        wait: config.wait,
      });
    }
    return {};
  },
  hooks: {
    on_action: {
      before: ["@nikitajs/core/src/plugins/metadata/schema"],
      handler: function ({ config }) {
        for (const name in config.containers) {
          config.containers[name].container = name;
        }
      },
    },
  },
  metadata: {
    definitions: definitions,
  },
};
