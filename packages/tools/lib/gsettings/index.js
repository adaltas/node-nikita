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
    if (config.argument != null) {
      config.properties = config.argument;
    }
    if (config.properties == null) {
      config.properties = {};
    }
    const results = [];
    for (const path in config.properties) {
      const properties = config.properties[path];
      results.push(
        await async function () {
          const results1 = [];
          for (const key in properties) {
            const value = properties[key];
            results1.push(
              await this.execute({
                command: dedent`
                  gsettings get ${path} ${key} | grep -x "${value}" && exit 3
                  gsettings set ${path} ${key} "${value}"
                `,
                code: [0, 3],
              }),
            );
          }
          return results1;
        }.call(this),
      );
    }
    return results;
  },
  metadata: {
    definitions: definitions,
  },
};
