// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function() {
    const {data, $status} = await this.lxc.query({
      path: "/1.0/resources"
    });
    return {
      $status: $status,
      config: data
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
