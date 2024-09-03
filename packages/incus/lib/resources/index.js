// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function () {
    const { data, $status } = await this.incus.query({
      path: "/1.0/resources",
    });
    return {
      $status: $status,
      config: data,
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
