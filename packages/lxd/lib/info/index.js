// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    // Check if container exist
    return await this.lxc.query({
      path: `/1.0/instances/${config.container}`,
      code: [0, 1],
    });
  },
  metadata: {
    argument_to_config: "container",
    definitions: definitions,
  },
};
