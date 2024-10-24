// Dependencies
import { db } from "@nikitajs/db/utils";
// Schema
// import definitions from "./schema.json" with { type: "json" };
import { readFile } from "node:fs/promises";
const definitions = JSON.parse(
  await readFile(new URL("./schema.json", import.meta.url), "utf8"),
);

// Action
export default {
  handler: async function ({ config }) {
    // Avoid errors when database argument is provided in the command:
    // - Postgres: "ERROR:  cannot drop the currently open database"
    // - MariaDB: "ERROR 1049 (42000): Unknown database 'my_db'"
    await this.db.query({
      ...db.connection_config(config),
      command: `DROP DATABASE IF EXISTS ${config.database};`,
      code: [0, 2],
      database: null,
    });
  },
  metadata: {
    argument_to_config: "database",
    global: "db",
    definitions: definitions,
  },
};
