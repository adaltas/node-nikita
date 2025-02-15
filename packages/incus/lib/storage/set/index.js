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
    // Current configuration retrieval
    const { storage } = await this.incus.storage.show(config.name);
    // Change detection
    const changes = diff(storage.config, config.properties);
    if (!Object.keys(changes).length) return false;
    // Changes persistence
    await this.incus.query({
      path: `/1.0/storage-pools/${config.name}`,
      data: {
        config: {
          ...storage.config,
          ...config.properties,
        },
        description: config.description ?? storage.description,
      },
      request: "PUT",
    });
    return true;
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
