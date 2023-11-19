// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const cmd_list_tables = config.engine === 'postgresql'
      ? `SELECT datname FROM pg_database WHERE datname = '${config.database}';`
      : config.engine === 'mariadb' || config.engine === 'mysql'
      ? `SHOW DATABASES;`
      : undefined;
    const {$status} = await this.db.query(config, {
      command: cmd_list_tables,
      database: null,
      grep: config.database
    });
    return {
      exists: $status
    };
  },
  metadata: {
    argument_to_config: 'database',
    global: 'db',
    shy: true,
    definitions: definitions
  }
};
