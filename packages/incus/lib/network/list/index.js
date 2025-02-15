// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function () {
    const { data: networks } = await this.incus.query({
      path: "/1.0/networks",
      query: {
        recursion: "1",
      },
    });
    return { $status: true, networks };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
