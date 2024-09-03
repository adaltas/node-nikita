// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: function ({ config }) {
    this.execute({
      command: `groupdel ${config.name}`,
      code: [0, 6],
    });
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
