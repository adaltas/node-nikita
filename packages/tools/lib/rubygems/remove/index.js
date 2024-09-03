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
    if (config.gem_bin == null) {
      config.gem_bin = "gem";
    }
    const version = config.version ? `-v ${config.version}` : "-a";
    await this.execute({
      command: dedent`
        ${config.gem_bin} list -i ${config.name} || exit 3
        ${config.gem_bin} uninstall ${config.name} ${version}
      `,
      code: [0, 3],
      bash: config.bash,
    });
  },
  metadata: {
    global: "ruby",
    definitions: definitions,
  },
};
