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
    const { stdout } = await this.db.query({
      ...db.connection_config(config),
      database: undefined,
      command: (function () {
        switch (config.engine) {
          case "mariadb":
          case "mysql":
            return `SELECT User FROM mysql.user WHERE User = '${config.username}'`;
          case "postgresql":
            return `SELECT '${config.username}' FROM pg_roles WHERE rolname='${config.username}'`;
        }
      })(),
      trim: true,
    });
    return {
      exists: stdout === config.username,
    };
  },
  metadata: {
    argument_to_config: "username",
    global: "db",
    shy: true,
    definitions: definitions,
  },
};
