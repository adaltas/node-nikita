// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {$status} = await this.incus.exec({
      $header: `Check if file exists in container ${config.container}`,
      container: config.container,
      command: `test -f ${config.target}`,
      code: [0, 1]
    });
    return {
      exists: $status
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
