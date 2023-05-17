// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    let {$status, data} = await this.lxc.query({
      path: `/1.0/storage-pools/${config.pool}/volumes/${config.type}`,
      code: [0, 1]
    });
    if(!Array.isArray(data)){
      data = [] // empty list of volumes return `{}` instead of `[]`
    }
    return {
      $status: $status,
      list: data.map( paths => paths.split('/').pop())
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
