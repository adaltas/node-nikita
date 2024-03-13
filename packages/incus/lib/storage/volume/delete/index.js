// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Actions
export default {
  handler: async function({config}) {
    const {$status} = await this.incus.query({
      path: `/1.0/storage-pools/${config.pool}/volumes/${config.type}/${config.name}`,
      request: "DELETE",
      format: 'string',
      code: [0, 1]
    });
    return {
      $status: $status
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
