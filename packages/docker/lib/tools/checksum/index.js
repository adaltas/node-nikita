
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function({
    config,
    tools: {log}
  }) {
    log({
      message: `Getting image checksum :${config.image}`,
      level: 'DEBUG'
    });
    // Run `docker images` with the following config:
    // - `--no-trunc`: display full checksum
    // - `--quiet`: discard headers
    const {$status, stdout} = await this.docker.tools.execute({
      boot2docker: config.boot2docker,
      command: `images --no-trunc --quiet ${config.image}:${config.tag}`,
      compose: config.compose,
      machine: config.machine
    });
    const checksum = stdout === '' ? undefined : stdout.toString().trim();
    if ($status) {
      log({
        message: `Image checksum for ${config.image}: ${checksum}`,
        level: 'INFO'
      });
    }
    return {
      $status: $status,
      checksum: checksum
    };
  },
  hooks: {
    on_action: function({config}) {
      if (config.repository) {
        throw Error('Configuration `repository` is deprecated, use `image` instead');
      }
    }
  },
  metadata: {
    definitions: definitions,
    global: "docker",
  }
};
