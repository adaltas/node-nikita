
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function({config}) {
    await this.docker.tools.execute({
      command: `volume rm ${config.name}`,
      code: [0, 1]
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
