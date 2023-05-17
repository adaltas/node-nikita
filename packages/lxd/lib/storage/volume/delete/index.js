// Dependencies
const definitions = require('./schema.json');

// Actions
module.exports = {
  handler: async function({config}) {
    const {$status} = await this.lxc.query({
      path: `/1.0/storage-pools/${config.pool}/volumes/${config.type}/${config.name}`,
      request: "DELETE",
      format: 'string',
      code: [0, 1]
    });
    return {
      $status: $status
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
