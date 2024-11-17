// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    return await this.incus.query({
      path: `/1.0/networks/${config.name}`,
      request: "DELETE",
      format: "string",
      code: [0, 1],
    });
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
