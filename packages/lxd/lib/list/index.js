
// Dependencies
const definitions = require('./schema.json');

// ## Exports
module.exports = {
  handler: async function({config}) {
    const {data} = (await this.lxc.query({
      $shy: false,
      path: `/1.0/${config.filter}`
    }));
    return {
      list: data.map(line => line.split('/').pop())
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
