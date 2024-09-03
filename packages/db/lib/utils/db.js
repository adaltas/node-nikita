import utils from "@nikitajs/core/utils";

// Escape SQL for Bash processing.
const escape = function (sql) {
  return sql.replace(/[\\"]/g, "\\$&");
};

// Build the CLI query command.
const command = function (...opts) {
  const config = {};
  for (let opt of opts) {
    if (typeof opt === "string") {
      opt = {
        command: opt,
      };
    }
    for (const k in opt) {
      config[k] = opt[k];
    }
  }
  if (!config.admin_username) {
    throw utils.error("NIKITA_DB_UTILS_REQUIRED_ARGUMENTS", [
      'Missing required argument: "admin_username"',
    ]);
  }
  if (!config.admin_password) {
    throw utils.error("NIKITA_DB_UTILS_REQUIRED_ARGUMENTS", [
      'Missing required argument: "admin_password"',
    ]);
  }
  if (!config.host) {
    throw utils.error("NIKITA_DB_UTILS_REQUIRED_ARGUMENTS", [
      'Missing required argument: "host"',
    ]);
  }
  switch (config.engine) {
    case "mariadb":
    case "mysql":
      if (config.path == null) {
        config.path = "mysql";
      }
      if (config.port == null) {
        config.port = "3306";
      }
      return [
        `${config.path}`,
        `-h${config.host}`,
        `-P${config.port}`,
        `-u${config.admin_username}`,
        `-p'${config.admin_password}'`,
        config.database ? `-D${config.database}` : void 0,
        config.mysql_config ? `${config.mysql_config}` : void 0,
        // -N, --skip-column-names   Don't write column names in results.
        // -s, --silent              Be more silent. Print results with a tab as separator, each row on new line.
        // -r, --raw                 Write fields without conversion. Used with --batch.
        config.silent ? "-N -s -r" : void 0,
        config.command ? `-e "${escape(config.command)}"` : void 0,
      ]
        .filter(Boolean)
        .join(" ");
    case "postgresql":
      if (config.path == null) {
        config.path = "psql";
      }
      if (config.port == null) {
        config.port = "5432";
      }
      return [
        `PGPASSWORD=${config.admin_password}`,
        `${config.path}`,
        `-h ${config.host}`,
        `-p ${config.port}`,
        `-U ${config.admin_username}`,
        config.database ? `-d ${config.database}` : void 0,
        config.postgres_config ? `${config.postgres_config}` : void 0,
        // -t, --tuples-only        Print rows only
        // -A, --no-align           Unaligned table output mode
        // -q, --quiet              Run quietly (no messages, only query output)
        "-tAq",
        config.command ? `-c "${config.command}"` : void 0,
      ]
        .filter(Boolean)
        .join(" ");
    default:
      throw Error(`Unsupported engine: ${JSON.stringify(config.engine)}`);
  }
};

/*
Parse JDBC URL

Enrich the result of `url.parse` with the "engine" and "db" properties.

Example:

```
parse 'jdbc:mysql://host1:3306,host2:3306/hive?createDatabaseIfNotExist=true'
{ engine: 'mysql',
  addresses:
    [ { host: 'host1', port: '3306' },
      { host: 'host2', port: '3306' } ],
  database: 'hive' }
```
*/
const jdbc = function (jdbc) {
  if (/^jdbc:mysql:/.test(jdbc)) {
    let [, , addresses, database] =
      /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec(jdbc);
    return {
      engine: "mysql",
      addresses: addresses.split(",").map(function (address) {
        const [host, port] = address.split(":");
        return {
          host: host,
          port: port || 3306,
        };
      }),
      database: database,
    };
  } else if (/^jdbc:postgresql:/.test(jdbc)) {
    let [, , addresses, database] =
      /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec(jdbc);
    return {
      engine: "postgresql",
      addresses: addresses.split(",").map(function (address) {
        const [host, port] = address.split(":");
        return {
          host: host,
          port: port || 5432,
        };
      }),
      database: database,
    };
  } else {
    throw Error("Invalid JDBC URL");
  }
};

// Filter connection properties
const connection_config = function (opts) {
  return utils.object.filter(
    opts,
    [],
    [
      "admin_username",
      "admin_password",
      "database",
      "engine",
      "host",
      "port",
      "silent",
    ],
  );
};

export { escape, command, jdbc, connection_config };

export default {
  escape: escape,
  command: command,
  jdbc: jdbc,
  connection_config: connection_config,
};
