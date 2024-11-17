// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function () {
    const { $status, data: resources } = await this.incus.query({
      path: "/1.0/resources",
    });
    return {
      $status: $status,
      resources,
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
