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
    for (const k in config.properties) {
      const v = config.properties[k];
      if (typeof v === "string") {
        continue;
      }
      config.properties[k] = v.toString();
    }
    // Check if exists
    const exists = await this.incus.storage
      .exists(config.name)
      .then(({ exists }) => exists);
    // Create if it does not exists
    await this.incus.query({
      $shy: false,
      $unless: exists,
      path: `/1.0/storage-pools`,
      data: {
        config: config.properties,
        description: config.description,
        name: config.name,
        driver: config.driver,
      },
      request: "POST",
    });
    if (!exists) {
      return;
    }
    // Storage already exists, find the changes
    if (config.properties == null) {
      return;
    }
    return this.incus.storage.set({
      name: config.name,
      description: config.description,
      properties: config.properties,
    });
  },
  metadata: {
    definitions: definitions,
  },
};
