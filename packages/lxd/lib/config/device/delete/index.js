// Dependencies
const definitions = require('./schema.json');

// ## Exports
module.exports = {
  handler: async function({config}) {
    const {properties} = (await this.lxc.config.device.show({
      container: config.container,
      device: config.device
    }));
    if (!properties) {
      return {
        $status: false
      };
    }
    const {$status} = (await this.execute({
      command: ['lxc', 'config', 'device', 'remove', config.container, config.device].join(' ')
    }));
    return {
      $status: $status
    };
  },
  metadata: {
    definitions: definitions
  }
};
