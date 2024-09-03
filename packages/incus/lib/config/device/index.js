// Dependencies
import diff from "object-diff";
import utils from "@nikitajs/incus/utils";
import { escapeshellarg as esa } from "@nikitajs/utils/string";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // No properties, dont go further
    if (Object.keys(config.properties).length === 0) return false;
    // Normalize config
    for (const key in config.properties) {
      const value = config.properties[key];
      if (typeof value === "string") {
        continue;
      }
      config.properties[key] = value.toString();
    }
    // Obtain current device properties
    const { properties } = await this.incus.config.device.show({
      container: config.container,
      device: config.device,
    });
    try {
      if (!properties) {
        // Device not registered, we need to use `add`
        await this.execute({
          command: [
            "incus",
            "config",
            "device",
            "add",
            config.container,
            config.device,
            config.type,
            ...Object.keys(config.properties).map(
              (key) => esa(key) + "=" + esa(config.properties[key]),
            ),
          ].join(" "),
        });
        return true;
      } else {
        // Device registered, we need to use `set`
        const changes = diff(properties, config.properties);
        if (Object.keys(changes).length === 0) return false;
        for (const key in changes) {
          const value = changes[key];
          await this.execute({
            command: [
              "incus",
              "config",
              "device",
              "set",
              config.container,
              config.device,
              key,
              esa(value),
            ].join(" "),
          });
        }
        return true;
      }
    } catch (error) {
      utils.stderr_to_error_message(error, error.stderr);
      throw error;
    }
  },
  metadata: {
    definitions: definitions,
  },
};
