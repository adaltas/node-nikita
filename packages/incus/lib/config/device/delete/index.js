// Dependencies
import definitions from "./schema.json" with { type: "json" };

// ## Exports
export default {
  handler: async function({config}) {
    const {properties} = (await this.incus.config.device.show({
      container: config.container,
      device: config.device
    }));
    if (!properties) {
      return {
        $status: false
      };
    }
    const {$status} = (await this.execute({
      command: ['incus', 'config', 'device', 'remove', config.container, config.device].join(' ')
    }));
    return {
      $status: $status
    };
  },
  metadata: {
    definitions: definitions
  }
};
