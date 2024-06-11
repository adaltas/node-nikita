// Dependencies
import { db } from "@nikitajs/db/utils";
import definitions from "./schema.json" with { type: "json" };

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
