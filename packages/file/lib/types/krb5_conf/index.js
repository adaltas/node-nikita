// Dependencies
const utils = require('../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    return await this.file.ini({
      parse: utils.ini.parse_brackets_then_curly,
      stringify: utils.ini.stringify_brackets_then_curly
    }, config);
  },
  metadata: {
    definitions: definitions
  }
};
