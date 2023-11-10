
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config }) {
    // Normalization
    if (config.detach == null) {
      config.detach = true;
    }
    if (config.rm == null) {
      config.rm = false;
    }
    // Execution
    await this.docker.run(config);
  },
  metadata: {
    definitions: definitions,
    global: "docker",
  }
};
