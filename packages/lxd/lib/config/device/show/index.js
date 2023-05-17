// Dependencies
const definitions = require('./schema.json');

// ## Exports
module.exports = {
  handler: async function({config}) {
    const {data} = (await this.lxc.query({
      path: '/' + ['1.0', 'instances', config.container].join('/')
    }));
    return {
      $status: true,
      properties: data.devices[config.device]
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
