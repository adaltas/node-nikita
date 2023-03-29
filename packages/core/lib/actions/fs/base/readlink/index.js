
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
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
