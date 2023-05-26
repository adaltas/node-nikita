// Dependencies
const path = require('path');
const utils = require('../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    // Set the target directory to yum's default path if target is a file name
    config.target = path.resolve("/etc/yum.repos.d", config.target);
    await this.file.ini(
      {
        parse: utils.ini.parse_multi_brackets,
      },
      config,
      {
        // Dont escape the section's header, headers are only one level and
        // contains versions with dots.
        escape: false,
      }
    );
  },
  metadata: {
    definitions: definitions
  }
};
