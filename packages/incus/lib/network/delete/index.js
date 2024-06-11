// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    return await this.incus.query({
      path: `/1.0/networks/${config.network}`,
      request: 'DELETE',
      format: 'string',
      code: [0, 1]
    });
  },
  metadata: {
    definitions: definitions
  }
};
