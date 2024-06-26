// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {data, $status} = await this.incus.query({
      path: `/1.0/instances/${config.container}/state`
    });
    return {
      $status: $status,
      config: data
    };
  },
  metadata: {
    argument_to_config: 'container',
    definitions: definitions
  }
};
