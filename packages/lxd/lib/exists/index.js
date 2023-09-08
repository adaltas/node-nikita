// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function ({ config }) {
    // Check if container exist
    const { $status } = await this.lxc.query({
      path: `/1.0/instances/${config.container}`,
      code: [0, 1],
    });
    return { exists: $status };
  },
  metadata: {
    argument_to_config: "container",
    definitions: definitions,
  },
};
