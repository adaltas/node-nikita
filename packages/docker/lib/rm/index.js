
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function({config}) {
    const {
      $status: exists,
      data: running
    } = await this.docker.tools.execute({
      $templated: false,
      command: `inspect ${config.container} --format '{{ json .State.Running }}'`,
      code: [0, 1],
      format: 'json'
    });
    if (!exists) {
      return false;
    }
    if (running && !config.force) {
      throw Error('Container must be stopped to be removed without force');
    }
    await this.docker.tools.execute({
      command: [
        'rm',
        ...(['link',
        'volumes',
        'force'].filter(function(opt) {
          return config[opt];
        }).map(function(opt) {
          return `-${opt.charAt(0)}`;
        })),
        config.container
      ].join(' ')
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
