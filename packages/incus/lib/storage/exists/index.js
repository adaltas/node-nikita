// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { storages } = await this.incus.storage.list();
    return {
      exists: !!storages.find((storage) => storage.name === config.name),
    };
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
