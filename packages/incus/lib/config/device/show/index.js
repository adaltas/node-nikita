// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// ## Exports
export default {
  handler: async function ({ config }) {
    const { data } = await this.incus.query({
      path: `/1.0/instances/${config.name}`,
    });
    return {
      $status: true,
      properties: data.devices[config.device],
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
