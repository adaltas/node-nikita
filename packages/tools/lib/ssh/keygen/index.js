
// Dependencies
const definitions = require("./schema.json");
const esa = require('@nikitajs/core/lib/utils').string.escapeshellarg;

// Action
module.exports = {
  handler: async function({
    config,
    tools: {path}
  }) {
    await this.fs.mkdir({
      target: `${path.dirname(config.target)}`
    });
    await this.execute({
      $unless_exists: `${config.target}`,
      command: [
        'ssh-keygen',
        "-q", // Silence
        `-t ${config.type}`,
        `-b ${config.bits}`,
        config.key_format && `-m ${esa(config.key_format)}`,
        config.comment && `-C ${esa(config.comment)}`,
        `-N ${esa(config.passphrase)}`,
        `-f ${esa(config.target)}`
      ].filter(Boolean).join(' ')
    });
  },
  metadata: {
    definitions: definitions
  }
};
