// Dependencies
const {merge} = require('mixme');
const utils = require('../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    const parse = config.parse || utils.ini.parse;
    const {data} = (await this.fs.base.readFile({
      target: config.target,
      encoding: config.encoding
    }));
    return {
      data: merge(parse(data, config))
    };
  },
  metadata: {
    definitions: definitions
  }
};
