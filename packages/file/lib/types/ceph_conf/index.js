// Dependencies
const path = require('path');
const utils = require('../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    if (config.rootdir) {
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    return await this.file.ini(
      {
        stringify: utils.ini.stringify,
        parse: utils.ini.parse_multi_brackets,
        escape: false,
      },
      config
    );
  },
  metadata: {
    definitions: definitions
  }
};
