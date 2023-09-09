
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    // Normalization
    if (config.uid === false) {
      config.uid = null;
    }
    if (config.gid === false) {
      config.gid = null;
    }
    // Validation
    if (!((config.uid != null) || (config.gid != null))) {
      throw Error("Missing one of uid or gid option");
    }
    await this.execute(
      [
        config.uid != null ? `chown ${config.uid} ${config.target}` : void 0,
        config.gid != null ? `chgrp ${config.gid} ${config.target}` : void 0,
      ].join("\n")
    );
  },
  hooks: {
    on_action: function({config}) {
      if (typeof config.uid === 'string' && /\d+/.test(config.uid)) {
        // String to integer coercion
        config.uid = parseInt(config.uid);
      }
      if (typeof config.gid === 'string' && /\d+/.test(config.gid)) {
        config.gid = parseInt(config.gid);
      }
    }
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
