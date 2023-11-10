
// Dependencies
const definitions = require("./schema.json");
const utils = require("../../utils");
const esa = utils.string.escapeshellarg;

// Action
module.exports = {
  handler: async function({config}) {
    const command = [
      'logout',
      config.registry && esa(config.registry)
    ].filter(Boolean).map(' ');
    await this.docker.tools.execute({
      command: command
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
