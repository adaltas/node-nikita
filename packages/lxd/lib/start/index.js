// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Check if container is not already running
    const {$status: running} = await this.lxc.running(config.container)
    if (running) {
      return false;
    }
    // Start the container
    return await this.execute({
      command: ['lxc', 'start', config.container].join(' '),
      code: [0, 42]
    });
  },
  metadata: {
    argument_to_config: 'container',
    definitions: definitions
  }
};
