// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    const {data, $status} = (await this.lxc.query({
      path: `/1.0/instances/${config.container}/state`
    }));
    return {
      $status: $status,
      config: data
    };
  },
  metadata: {
    argument_to_config: 'container',
    definitions: definitions
  }
};
