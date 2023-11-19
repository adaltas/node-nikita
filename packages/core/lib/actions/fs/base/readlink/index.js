
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const {stdout} = await this.execute({
      command: `readlink ${config.target}`
    });
    return {
      target: stdout.trim()
    };
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
