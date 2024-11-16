// Dependencies
import dedent from "dedent";
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
    const { exists } = await this.incus.project.exists(config.name);
    if (exists) return false;
    await this.incus.query({
      $shy: false,
      path: `/1.0/projects`,
      data: {
        config: {},
        description: config.description,
        name: config.name,
      },
      request: "POST",
    });
    return true;
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
