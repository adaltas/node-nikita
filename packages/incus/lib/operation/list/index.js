// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function () {
    const { data: operations } = await this.incus.query({
      path: `/1.0/operations`,
      query: {
        recursion: "1",
      },
    });
    return { $status: true, operations };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
