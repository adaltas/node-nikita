
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    return await this.execute({
      command: `mv ${config.source} ${config.target}`,
      trim: true
    });
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
