// Dependencies
import { db } from "@nikitajs/db/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    return {
      exists: await this.db
        .query({
          ...db.connection_config(config),
          command: `SELECT 1 FROM pg_namespace WHERE nspname = '${config.schema}';`,
          grep: "1",
        })
        .then(({ $status: exists }) => exists),
    };
  },
  metadata: {
    global: "db",
    definitions: definitions,
  },
};
