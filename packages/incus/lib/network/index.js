// Dependencies
import dedent from "dedent";
import yaml from "js-yaml";
import diff from "object-diff";
import { merge } from "mixme";
import { escapeshellarg as esa } from "@nikitajs/utils/string";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// ## Exports
export default {
  handler: async function ({ config }) {
    // Normalize config
    for (const key in config.properties) {
      config.properties[key] = config.properties[key].toString();
    }
    // Command if the network does not yet exist
    const { exists } = await this.incus.network.exists(config.name);
    await this.incus.query({
      $unless: exists,
      path: "/1.0/networks",
      data: {
        config: config.properties,
        name: config.name,
        type: config.type,
      },
      request: "POST",
    });
    if (!exists) return true;
    // Network already exists, find the changes
    return this.incus.network.set({
      name: config.name,
      properties: config.properties,
      description: config.description,
    });
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
