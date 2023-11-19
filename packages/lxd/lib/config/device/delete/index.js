// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// ## Exports
export default {
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
