
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function({config}) {
    await this.docker.tools.execute({
      command: `pause ${config.container}`
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
