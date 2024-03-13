// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// ## Exports
export default {
  handler: async function({config}) {
    const {data} = (await this.incus.query({
      path: '/' + ['1.0', 'instances', config.container].join('/')
    }));
    return {
      $status: true,
      properties: data.devices[config.device]
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
