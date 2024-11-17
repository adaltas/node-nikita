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
    const { data: storage } = await await this.incus.query({
      $shy: false,
      path: `/1.0/storage-pools/${config.name}`,
    });
    return { storage };
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
