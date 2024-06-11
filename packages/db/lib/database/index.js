// Dependencies
import dedent from "dedent";
import { db } from "@nikitajs/db/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // Defines and check the engine type
    config.engine = config.engine.toLowerCase();
    log("DEBUG", `Database engine set to ${config.engine}`);
    const engine =
      config.engine === "mysql" || config.engine === "mariadb"
        ? "mysql"
        : "postgresql";
    if (engine === "mysql") {
      config.character_set ??= "latin1"; // MySQL default
      switch (config.character_set) {
        case "latin1":
          config.collation ??= "latin1_swedish_ci"; // MySQL default
          break;
        case "utf8":
          config.collation ??= "utf8_general_ci";
      }
    }
    // Create the database if it does not exists
    log("DEBUG", `Check if database ${config.database} exists`);
    const { exists } = await this.db.database.exists(
      db.connection_config(config)
    );
    if (!exists) {
      await this.execute({
        command:
          engine === "mysql"
            ? db.command(
                config,
                {
                  database: null,
                },
                [
                  `CREATE DATABASE ${config.database}`,
                  `DEFAULT CHARACTER SET ${config.character_set}`,
                  config.collation
                    ? `DEFAULT COLLATE ${config.collation}`
                    : void 0,
                  ";",
                ].join(" ")
              )
            : db.command(
                config,
                {
                  database: null,
                },
                `CREATE DATABASE ${config.database};`
              ),
      });
      log("WARN", `Database created: ${JSON.stringify(config.database)}`);
    }
    // Associate users to the database
    for (const user of config.user) {
      log(
        "DEBUG",
        `Check if user ${user} has PRIVILEGES on ${config.database} `
      );
      const { exists } = await this.db.user.exists({
        ...db.connection_config(config),
        username: user,
      });
      if (!exists) {
        throw Error(`DB user does not exists: ${user}`);
      }
      const command_has_privileges =
        engine === "mysql"
          ? db.command(
              config,
              {
                database: "mysql",
              },
              `SELECT user FROM db WHERE db='${config.database}';`
            ) + ` | grep '${user}'`
          : db.command(
              config,
              {
                database: config.database,
              },
              "\\l"
            ) + ` | egrep '^${user}='`;
      const command_grant_privileges =
        engine === "mysql"
          ? db.command(
              config,
              {
                database: null,
              },
              `GRANT ALL PRIVILEGES ON ${config.database}.* TO '${user}' WITH GRANT OPTION;`
            )
          : db.command(
              config,
              {
                database: null,
              },
              `GRANT ALL PRIVILEGES ON DATABASE ${config.database} TO ${user}`
            );
      const { $status } = await this.execute({
        command: dedent`
          if ${command_has_privileges}; then
            echo '[INFO] User already with privileges'
            exit 3
          fi
          echo '[WARN] User privileges granted'
          ${command_grant_privileges}
        `,
        code: [0, 3],
      });
      if ($status) {
        log("WARN", `Privileges granted: to ${user} on ${config.database}`);
      }
    }
  },
  metadata: {
    argument_to_config: "database",
    global: "db",
    definitions: definitions,
  },
};
