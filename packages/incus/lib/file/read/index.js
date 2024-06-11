// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    let {data} = (await this.incus.query({
      $header: `Check if file exists in container ${config.container}`,
      path: `/1.0/instances/${config.container}/files?path=${config.target}`,
      format: 'string'
    }));
    if (config.trim) {
      data = data.trim();
    }
    return {
      $status: true,
      data: data
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
