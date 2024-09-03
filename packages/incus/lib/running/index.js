// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    return await this.execute({
      command: `incus list -c ns --format csv | grep '${config.container},RUNNING' || exit 42`,
      code: [0, 42],
    });
  },
  metadata: {
    argument_to_config: "container",
    definitions: definitions,
    shy: true,
  },
};
