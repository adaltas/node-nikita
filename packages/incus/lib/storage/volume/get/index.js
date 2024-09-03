// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    const { $status, data } = await this.incus.query({
      path: `/1.0/storage-pools/${config.pool}/volumes/${config.type}/${config.name}`,
      code: [0, 1],
    });
    return {
      $status: $status,
      data: data,
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
