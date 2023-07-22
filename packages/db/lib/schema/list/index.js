// Dependencies
const utils = require('@nikitajs/core/lib/utils');
const definitions = require('./schema.json');

// ## Exports
module.exports = {
  handler: async function({config}) {
    const {stdout} = await this.db.query(config, {
      command: '\\dn',
      trim: true
    });
    const schemas = utils.string.lines(stdout).map(function(line) {
      const [name, owner] = line.split('|');
      return {
        name: name,
        owner: owner
      };
    });
    return {
      schemas: schemas
    };
  },
  metadata: {
    argument_to_config: 'database',
    global: 'db',
    definitions: definitions
  }
};
