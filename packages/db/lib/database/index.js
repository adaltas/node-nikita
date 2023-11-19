// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" assert { type: "json" };
import utils from "@nikitajs/db/utils";

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    if (config.user == null) {
      config.user = [];
    }
    if (typeof config.user === "string") {
      config.user = [config.user];
    }
    // Defines and check the engine type
    config.engine = config.engine.toLowerCase();
    log({
      message: `Database engine set to ${config.engine}`,
      level: "DEBUG",
    });
    const engine = config.engine === 'mysql' || config.engine === 'mariadb'
      ? "mysql"
      : "postgresql"
    if (engine === "mysql") {
      if (config.character_set == null) {
        config.character_set = "latin1"; // MySQL default
      }
      switch (config.character_set) {
        case "latin1":
          if (config.collation == null) {
            config.collation = "latin1_swedish_ci"; // MySQL default
          }
          break;
        case "utf8":
          if (config.collation == null) {
            config.collation = "utf8_general_ci";
          }
      }
    }
    // Create the database if it does not exists
    log({
      message: `Check if database ${config.database} exists`,
      level: "DEBUG",
    });
    const { exists } = await this.db.database.exists(config);
    if (!exists) {
      await this.execute({
        command: engine === "mysql"
          ? utils.db.command(
              config,
              {
                database: null,
              },
              [
                `CREATE DATABASE ${config.database}`,
                `DEFAULT CHARACTER SET ${config.character_set}`,
                config.collation ? `DEFAULT COLLATE ${config.collation}` : void 0,
                ";",
              ].join(" ")
            )
          : utils.db.command(
              config,
              {
                database: null,
              },
              `CREATE DATABASE ${config.database};`
            ),
      });
      log({
        message: `Database created: ${JSON.stringify(config.database)}`,
        level: "WARN",
      });
    }
    // Associate users to the database
    for (const user of config.user) {
      log({
        message: `Check if user ${user} has PRIVILEGES on ${config.database} `,
        level: "DEBUG",
      });
      const { exists } = await this.db.user.exists(config, {
        username: user,
      });
      if (!exists) {
        throw Error(`DB user does not exists: ${user}`);
      }
      const command_has_privileges = engine === "mysql"
        ? utils.db.command(
          config,
          {
            database: "mysql",
          },
          `SELECT user FROM db WHERE db='${config.database}';`
        ) + ` | grep '${user}'`
        : utils.db.command(
          config,
          {
            database: config.database,
          },
          "\\l"
        ) + ` | egrep '^${user}='`
      const command_grant_privileges = engine === "mysql"
        ? utils.db.command(
            config,
            {
              database: null,
            },
            `GRANT ALL PRIVILEGES ON ${config.database}.* TO '${user}' WITH GRANT OPTION;`
          )
        : utils.db.command(
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
        log({
          message: `Privileges granted: to ${user} on ${config.database}`,
          level: "WARN",
        });
      }
    }
  },
  metadata: {
    argument_to_config: "database",
    global: "db",
    definitions: definitions,
  },
};
