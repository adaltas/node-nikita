// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    let { $status, data: volumes } = await this.incus.query({
      path: `/1.0/storage-pools/${config.pool}/volumes/${config.type}`,
      code: [0, 1],
      query: {
        recursion: "1",
      },
    });
    if (!Array.isArray(volumes)) {
      volumes = []; // empty list of volumes return `{}` instead of `[]`
    }
    return {
      $status: $status,
      volumes,
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
