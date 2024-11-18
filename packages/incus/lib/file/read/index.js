// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    let { data } = await this.incus.query({
      path: `/1.0/instances/${config.name}/files?path=${config.target}`,
      format: "string",
    });
    if (config.trim) {
      data = data.trim();
    }
    return {
      $status: true,
      data: data,
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
