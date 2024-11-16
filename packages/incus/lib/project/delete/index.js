// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Recursion print the project configuration instead of its URL path.
    const { exists } = await this.incus.project.exists(config.name);
    if (!exists) return false;
    await this.incus.query({
      $shy: false,
      path: `/1.0/projects/${config.name}`,
      request: "DELETE",
    });
    return true;
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
