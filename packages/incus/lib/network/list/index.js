// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function () {
    const { data } = await this.incus.query({
      path: "/1.0/networks",
    });
    return {
      $status: true,
      list: data.map((line) => line.split("/").pop()),
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
