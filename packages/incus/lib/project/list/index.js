// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function () {
    // Note, incus cli add `recursion=1` to query parameters
    const { data: projects } = await this.incus.query({
      $shy: false,
      path: `/1.0/projects`,
      query: {
        recursion: 1,
      },
    });
    return { projects };
  },
  metadata: {
    definitions: definitions,
  },
};
