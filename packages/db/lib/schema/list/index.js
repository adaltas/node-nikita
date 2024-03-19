// Dependencies
import utils from "@nikitajs/core/utils";
import { db } from "@nikitajs/db/utils";
import definitions from "./schema.json" assert { type: "json" };

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
