// Dependencies
const quote = require('regexp-quote');
const definitions = require('./schema.json');

// Actions
module.exports = {
  handler: async function({config}) {
    const {data} = (await this.fs.base.readFile({
      target: config.target,
      encoding: config.encoding
    }));
    const properties = {};
    // Parse
    const lines = data.split(/\r\n|[\n\r\u0085\u2028\u2029]/g);
    for (const line of lines) {
      if (/^\s*$/.test(line)) { // Empty line
        continue;
      }
      if (/^#/.test(line)) { // Comment
        if (config.comment) {
          properties[line] = null;
        }
        continue;
      }
      let [_, k, v] = RegExp(`^(.*?)${quote(config.separator)}(.*)$`).exec(line);
      if (config.trim) {
        k = k.trim();
      }
      if (config.trim) {
        v = v.trim();
      }
      properties[k] = v;
    }
    return {
      properties: properties
    };
  },
  metadata: {
    definitions: definitions
  }
};
