// Dependencies
import dedent from "dedent";
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
      command: dedent`
        incus info ${config.name} > /dev/null || exit 42
        ${["incus", "delete", config.name, config.force ? "--force" : void 0].join(" ")}
      `,
      code: [0, 42],
    });
  },
  metadata: {
    argument_to_config: "name",
    definitions: definitions,
  },
};
