// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function() {
    const {data, $status} = await this.incus.query({
      path: "/1.0/resources"
    });
    return {
      $status: $status,
      config: data
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
