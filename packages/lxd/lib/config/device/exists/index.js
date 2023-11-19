// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// ## Exports
export default {
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
