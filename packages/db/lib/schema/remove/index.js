// Dependencies
import { db } from "@nikitajs/db/utils";
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    const { exists } = await this.db.schema.exists({
      ...db.connection_config(config),
      schema: config.schema,
    });
    if (!exists) {
      return false;
    }
    await this.db.query({
      ...db.connection_config(config),
      command: `DROP SCHEMA IF EXISTS ${config.schema};`,
    });
  },
  metadata: {
    argument_to_config: "schema",
    global: "db",
    definitions: definitions,
  },
};
