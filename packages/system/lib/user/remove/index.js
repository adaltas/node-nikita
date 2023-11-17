
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: function({config}) {
    this.execute({
      command: `userdel ${config.name}`,
      code: [0, 6]
    });
  },
  metadata: {
    argument_to_config: 'name'
  },
  definitions: definitions
};
