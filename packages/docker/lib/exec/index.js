
// Dependencies
const definitions = require("./schema.json");

// Action
module.exports = {
  handler: async function({
    config,
    tools: {log}
  }) {
    if (config.service == null) {
      config.service = false;
    }
    // Construct exec command
    let command = 'exec';
    if (config.uid != null) {
      command += ` -u ${config.uid}`;
      if (config.gid != null) {
        command += `:${config.gid}`;
      }
    } else if (config.gid != null) {
      log('WARN', 'config.gid ignored unless config.uid is provided');
    }
    command += ` ${config.container} ${config.command}`;
    return await this.docker.tools.execute({
      command: command,
      code: config.code
    });
  },
  metadata: {
    global: 'docker',
    definitions: definitions
  }
};
