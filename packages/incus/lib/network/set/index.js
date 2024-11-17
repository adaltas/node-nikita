// Dependencies
import diff from "object-diff";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Normalize config
    for (const key in config.properties) {
      config.properties[key] = config.properties[key].toString();
    }
    // Current configuration retrieval
    const { network } = await this.incus.network.show(config.name);
    // Change detection
    const changes = diff(network.config, config.properties);
    if (!Object.keys(changes).length) return false;
    // Changes persistence
    await this.incus.query({
      path: `/1.0/networks/${config.name}`,
      data: {
        config: {
          ...network.config,
          ...config.properties,
        },
        description: config.description ?? network.description,
      },
      request: "PUT",
    });
    return true;
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
    shy: true,
  },
};
