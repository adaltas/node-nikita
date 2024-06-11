
// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    const mode = typeof config.mode === 'number'
      ? config.mode.toString(8).slice(-4)
      : config.mode;
    await this.execute(`chmod ${mode} ${config.target}`);
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
