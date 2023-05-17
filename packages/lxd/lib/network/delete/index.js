// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    return await this.lxc.query({
      path: `/1.0/networks/${config.network}`,
      request: 'DELETE',
      format: 'string',
      code: [0, 1]
    });
  },
  metadata: {
    definitions: definitions
  }
};
