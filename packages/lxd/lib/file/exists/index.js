// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    const {$status} = await this.lxc.exec({
      $header: `Check if file exists in container ${config.container}`,
      container: config.container,
      command: `test -f ${config.target}`,
      code: [0, 1]
    });
    return {
      exists: $status
    };
  },
  metadata: {
    definitions: definitions,
    shy: true
  }
};
