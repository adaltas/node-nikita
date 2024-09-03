// Dependencies
import utils from "@nikitajs/core/utils";
import { db } from "@nikitajs/db/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// ## Exports
export default {
  handler: async function ({ config }) {
    const { stdout } = await this.db.query({
      ...db.connection_config(config),
      command: "\\dn",
      trim: true,
    });
    return {
      schemas: utils.string.lines(stdout).map((line) => {
        const [name, owner] = line.split("|");
        return {
          name: name,
          owner: owner,
        };
      }),
    };
  },
  metadata: {
    argument_to_config: "database",
    global: "db",
    definitions: definitions,
  },
};
