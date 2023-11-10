
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config }) {
    // Construct exec command
    await this.docker.tools.execute({
      command: `ps | egrep ' ${config.container}$'`,
      code: [0, 1],
    });
  },
  metadata: {
    definitions: definitions,
    global: "docker",
  },
};
