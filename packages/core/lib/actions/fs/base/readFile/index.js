
// Dependencies
const utils = require('../../../../utils');
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    // Normalize options
    const buffers = [];
    await this.fs.base.createReadStream({
      target: config.target,
      on_readable: function(rs) {
        const results = [];
        let buffer; while (buffer = rs.read()) {
          results.push(buffers.push(buffer));
        }
        return results;
      }
    });
    let data = Buffer.concat(buffers);
    if (config.encoding) {
      data = data.toString(config.encoding);
    }
    if (config.format) {
      data = await utils.string.format(data, config.format)
    }
    return {
      data: data
    };
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
