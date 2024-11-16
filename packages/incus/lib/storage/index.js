// Dependencies
import dedent from "dedent";
import yaml from "js-yaml";
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
    const { data } = await this.incus.storage.show(config.name);
    const changes = diff(data.config, config.properties);
    for (const key in changes) {
      const value = changes[key];
      await this.execute({
        command: [
          "incus",
          "storage",
          "set",
          config.name,
          key,
          `'${value.replace("'", "\\'")}'`,
        ].join(" "),
      });
    }
    return {
      $status: Object.keys(changes).length > 0,
    };
  },
  metadata: {
    definitions: definitions,
  },
};
