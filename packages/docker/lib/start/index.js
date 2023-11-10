
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
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
        module: 'nikita/lib/docker/start'
      });
    } else {
      log({
        message: `Starting container ${config.container}`,
        level: 'INFO',
        module: 'nikita/lib/docker/start'
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
