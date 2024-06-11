// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function () {
    const { data } = await this.incus.query({
      path: "/1.0/networks",
    });
    return {
      $status: true,
      list: data.map(line => line.split('/').pop())
    };
  },
  metadata: {
    definitions: definitions,
    shy: true,
  },
};
