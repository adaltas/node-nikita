
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: function({metadata, config}) {
    this.execute({
      command: `groupdel ${config.name}`,
      code: [0, 6]
    });
  },
  metadata: {
    argument_to_config: 'name',
    definitions: definitions
  }
};
