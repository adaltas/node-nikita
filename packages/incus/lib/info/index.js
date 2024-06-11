// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config }) {
    // Check if container exist
    return await this.incus.query({
      path: `/1.0/instances/${config.container}`,
      code: [0, 1],
    });
  },
  metadata: {
    argument_to_config: "container",
    definitions: definitions,
  },
};
