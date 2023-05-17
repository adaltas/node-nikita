// Dependencies
const definitions = require('./schema.json');

// ## Exports
module.exports = {
  handler: async function({config}) {
    const {properties} = (await this.lxc.config.device.show({
      container: config.container,
      device: config.device
    }));
    return {
      exists: !!properties,
      properties: properties
    };
  },
  metadata: {
    definitions: definitions
  }
};
