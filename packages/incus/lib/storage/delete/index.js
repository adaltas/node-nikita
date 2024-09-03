// Dependencies
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
    // Check if storage exists
    const { exists } = await this.incus.storage.exists(config.name);
    if (!exists) return false;
    // Remove the storage
    await this.execute({
      command: `incus storage delete ${esa(config.name)}`,
      code: [0, 42],
    });
    return true;
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
