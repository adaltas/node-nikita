// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Check if container is running
    const {$status: running} = await this.lxc.running(config.container)
    if (!running) {
      return false;
    }
    // Stop the container
    await this.execute({
      command: `lxc stop ${config.container}`,
      code: [0, 42]
    });
    if (config.wait) {
      await this.execute.wait({
        $shy: true,
        command: `lxc info ${config.container} | grep 'Status: STOPPED'`,
        retry: config.wait_retry,
        interval: config.wait_interval
      });
    }
    return true;
  },
  metadata: {
    argument_to_config: 'container',
    definitions: definitions
  }
};
