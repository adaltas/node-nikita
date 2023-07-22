// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    const {exists} = await this.db.schema.exists(config);
    if (!exists) {
      return false;
    }
    return await this.db.query(config, {
      command: `DROP SCHEMA IF EXISTS ${config.schema};`
    });
  },
  metadata: {
    argument_to_config: 'schema',
    global: 'db',
    definitions: definitions
  }
};
