// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Check if container is not already running
    const {$status: running} = await this.incus.running(config.container)
    if (running) {
      return false;
    }
    // Start the container
    return await this.execute({
      command: ['incus', 'start', config.container].join(' '),
      code: [0, 42]
    });
  },
  metadata: {
    argument_to_config: 'container',
    definitions: definitions
  }
};
