// Dependencies
import dedent from "dedent";
import definitions from "./schema.json" assert { type: "json" };
import utils from "@nikitajs/db/utils";

// Action
export default {
  handler: async function ({ config }) {
    // Commands
    const engine = config.engine === 'mysql' || config.engine === 'mariadb'
      ? "mysql"
      : "postgresql"
    const command_user_exists = engine === "mysql"
      ? utils.db.command(
          config,
          `SELECT User FROM mysql.user WHERE User='${config.username}'`
        ) + ` | grep ${config.username}`
      : utils.db.command(
          config,
          `SELECT 1 FROM pg_roles WHERE rolname='${config.username}'`
        ) + " | grep 1";
    const command_user_create = engine === "mysql"
      ? utils.db.command(
          config,
          `CREATE USER ${config.username} IDENTIFIED BY '${config.password}';`
        )
      : utils.db.command(
        config,
        `CREATE USER ${config.username} WITH PASSWORD '${config.password}';`
      );
    const command_password_is_invalid = engine === "mysql"
      ? utils.db.command(
          config,
          {
            admin_username: config.username,
            admin_password: config.password,
          },
          "\\dt"
        ) + " 2>&1 >/dev/null | grep -e '^ERROR 1045.*'"
      : utils.db.command(
        config,
        {
          admin_username: config.username,
          admin_password: config.password,
        },
        "\\dt"
      ) +
      " 2>&1 >/dev/null | grep -e '^.*\\sFATAL.*password\\sauthentication\\sfailed\\sfor\\suser.*'";
    const command_password_change =
      engine === "mysql"
        ? utils.db.command(
            config,
            // Old mysql version for MySQL 5.7.5 and earlier or MariaDB 10.1.20 and earlier
            // `SET PASSWORD FOR ${config.username} = PASSWORD ('${config.password}');`
            `ALTER USER ${config.username} IDENTIFIED BY '${config.password}';`
          )
        : engine === "mariadb"
        ? utils.db.command(
            config,
            `ALTER USER ${config.username} IDENTIFIED BY '${config.password}';`
          )
        : utils.db.command(
            config,
            `ALTER USER ${config.username} WITH PASSWORD '${config.password}';`
          );
    return await this.execute({
      command: dedent`
        signal=3
        if ${command_user_exists}; then
          echo '[INFO] User already exists'
        else
          ${command_user_create}
          echo '[WARN] User created'
          signal=0
        fi
        if [ $signal -eq 3 ]; then
          if ! ${command_password_is_invalid}; then
            echo '[INFO] Password not modified'
          else
            ${command_password_change}
            echo '[WARN] Password modified'
            signal=0
          fi
        fi
        exit $signal
      `,
      code: [0, 3],
      trap: true,
    });
  },
  metadata: {
    global: "db",
    definitions: definitions,
  },
};
