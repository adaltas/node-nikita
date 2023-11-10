
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function({config}) {
    // Old implementation was `wait {container} | read r; return $r`
    await this.docker.tools.execute(`wait ${config.container}`);
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
