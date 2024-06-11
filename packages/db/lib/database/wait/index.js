// Dependencies
import { db } from "@nikitajs/db/utils";
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const cmd_list_tables = config.engine === 'postgresql'
      ? `SELECT datname FROM pg_database WHERE datname = '${config.database}';`
      : config.engine === 'mariadb' || config.engine === 'mysql'
      ? `SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${config.database}';`
      : undefined;
    const {$status} = await this.wait({
      retry: config.retry,
      interval: config.interval,
    }, async function() {
      const { stdout } = await this.db.query({
        ...db.connection_config(config),
        command: cmd_list_tables,
        database: null,
        grep: config.database,
      });
      if(stdout.trim() === '') throw Error('NIKITA_DB_WAIT_NOT_READY')
    });
    return {
      exists: $status
    };
  },
  metadata: {
    argument_to_config: 'database',
    global: 'db',
    definitions: definitions
  }
};
