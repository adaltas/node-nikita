// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    // rm is false by default only if config.service is true
    const { $status } = await this.docker.tools.status(config, {
      $shy: true,
    });
    if ($status) {
      log({
        message: `Stopping container ${config.container}`,
        level: "INFO",
      });
    } else {
      log({
        message: `Container already stopped ${config.container} (Skipping)`,
        level: "INFO",
      });
    }
    await this.docker.tools.execute({
      $if: $status,
      command: [
        "stop",
        config.timeout != null ? `-t ${config.timeout}` : void 0,
        `${config.container}`,
      ].join(" "),
    });
  },
  metadata: {
    global: "docker",
    definitions: definitions,
  },
};
