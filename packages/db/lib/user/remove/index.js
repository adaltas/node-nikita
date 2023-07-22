// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    await this.db.query(config, {
      command: `DROP USER IF EXISTS ${config.username};`
    });
  },
  metadata: {
    argument_to_config: 'username',
    global: 'db',
    definitions: definitions
  }
};
