// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Pre hook
    if (config.pre_delete) {
      await this.call(config, config.pre_delete);
    }
    // Containers removal
    for (const name in config.containers) {
      await this.incus.delete({
        $header: `Container ${name} : delete`,
        container: name,
        force: config.force,
      });
    }
    // Networks removal
    for (const name in config.networks) {
      await this.incus.network.delete({
        $header: `Network ${name} : delete`,
        name: name,
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
