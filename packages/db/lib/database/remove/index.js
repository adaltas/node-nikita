// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    // Avoid errors when database argument is provided in the command:
    // - Postgres: "ERROR:  cannot drop the currently open database"
    // - MariaDB: "ERROR 1049 (42000): Unknown database 'my_db'"
    await this.db.query(config, {
      command: `DROP DATABASE IF EXISTS ${config.database};`,
      code: [0, 2],
      database: null,
    });
  },
  metadata: {
    argument_to_config: 'database',
    global: 'db',
    definitions: definitions
  }
};
