// Dependencies
const path = require('path');
const utils = require('../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    if (config.target == null) {
      config.target = `/etc/wireguard/${config.interface}.conf`;
    }
    if (config.rootdir) {
      config.target = `${path.join(config.rootdir, config.target)}`;
    }
    await this.file.ini(
      {
        parse: utils.ini.parse_multi_brackets,
        stringify: utils.ini.stringify_multi_brackets,
        indent: "",
      },
      config
    );
  },
  metadata: {
    definitions: definitions
  }
};
