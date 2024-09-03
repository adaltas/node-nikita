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
      container: config.container,
      device: config.device,
    });
    return {
      exists: !!properties,
      properties: properties,
    };
  },
  metadata: {
    definitions: definitions,
  },
};
