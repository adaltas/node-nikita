// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {$status} = await this.incus.query({
      path: `/1.0/storage-pools/${config.pool}/volumes/${config.type}`,
      request: "POST",
      data: JSON.stringify({
        name: config.name,
        config: config.properties != null ? config.properties : {},
        content_type: config.content != null ? config.content : null,
        description: config.description != null ? config.description : null
      }),
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
