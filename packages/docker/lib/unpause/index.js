
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: function({config}) {
    this.docker.tools.execute({
      command: `unpause ${config.container}`
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
