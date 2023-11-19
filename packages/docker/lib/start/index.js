
// Dependencies
import definitions from "./schema.json" assert { type: "json" };

// Action
export default {
  handler: async function({
    config,
    tools: {log}
  }) {
    const {$status} = await this.docker.tools.status(config, {
      $shy: true
    });
    if ($status) {
      log({
        message: `Container already started ${config.container} (Skipping)`,
        level: 'INFO',
      });
    } else {
      log({
        message: `Starting container ${config.container}`,
        level: 'INFO',
      });
    }
    await this.docker.tools.execute({
      $unless: $status,
      command: ['start', config.attach ? '-a' : void 0, `${config.container}`].join(' ')
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
