
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: function({config}) {
    return new Promise(function(resolve) {
      return setTimeout(resolve, config.time);
    });
  },
  metadata: {
    argument_to_config: 'time',
    definitions: definitions
  }
};
