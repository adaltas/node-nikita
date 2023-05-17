// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    let {data} = (await this.lxc.query({
      $header: `Check if file exists in container ${config.container}`,
      path: `/1.0/instances/${config.container}/files?path=${config.target}`,
      format: 'string'
    }));
    if (config.trim) {
      data = data.trim();
    }
    return {
      $status: true,
      data: data
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
