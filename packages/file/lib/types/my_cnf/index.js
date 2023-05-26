// Dependencies
const utils = require('../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    return await this.file.ini({
      stringify: utils.ini.stringify_single_key
    }, config);
  },
  metadata: {
    definitions: definitions
  }
};
