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
    const cmd_list_tables =
      config.engine === "postgresql" ?
        `SELECT datname FROM pg_database WHERE datname = '${config.database}';`
      : config.engine === "mariadb" || config.engine === "mysql" ?
        `SHOW DATABASES;`
      : undefined;
    const { $status } = await this.db.query({
      ...db.connection_config(config),
      command: cmd_list_tables,
      database: null,
      grep: config.database,
    });
    return {
      exists: $status,
    };
  },
  metadata: {
    argument_to_config: "database",
    global: "db",
    shy: true,
    definitions: definitions,
  },
};
