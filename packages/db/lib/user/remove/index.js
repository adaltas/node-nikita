// Dependencies
import { db } from "@nikitajs/db/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    await this.db.query({
      ...db.connection_config(config),
      command: `DROP USER IF EXISTS ${config.username};`
    });
  },
  metadata: {
    argument_to_config: 'username',
    global: 'db',
    definitions: definitions
  }
};
