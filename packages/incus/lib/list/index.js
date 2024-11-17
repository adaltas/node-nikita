// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// ## Exports
export default {
  handler: async function ({ config }) {
    let { data: instances } = await this.incus.query({
      $shy: false,
      path: `/1.0/instances`,
      query: {
        recursion: "1",
      },
    });
    if (config.type) {
      instances = instances.filter((instance) => instance.type === config.type);
    }
    return {
      instances,
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
