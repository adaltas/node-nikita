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
    const exists = await this.incus.project
      .list()
      .then(({ projects }) =>
        projects.some((project) => project.name === config.name),
      );
    return { exists };
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
