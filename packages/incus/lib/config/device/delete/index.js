// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// ## Exports
export default {
  handler: async function ({ config }) {
    const { properties } = await this.incus.config.device.show({
      name: config.name,
      device: config.device,
    });
    if (!properties) {
      return {
        $status: false,
      };
    }
    const { $status } = await this.execute({
      command: [
        "incus",
        "config",
        "device",
        "remove",
        config.name,
        config.device,
      ].join(" "),
    });
    return {
      $status: $status,
    };
  },
  metadata: {
    definitions: definitions,
  },
};
