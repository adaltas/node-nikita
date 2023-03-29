
// Dependencies
const utils = require('../../../../utils');
const definitions = require('./schema.json');

const {escapeshellarg} = utils.string;

// Action
module.exports = {
  handler: async function({config}) {
    await this.execute({
      command: `ln -sf ${escapeshellarg(config.source)} ${escapeshellarg(config.target)}`
    });
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
