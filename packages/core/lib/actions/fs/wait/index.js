// Dependencies
const definitions = require('./schema.json');

// Exports
module.exports = {
  handler: async function ({ config, tools: { log } }) {
    let status = false;
    // Validate parameters
    for (const target of config.target) {
      const { exists } = await this.fs.base.exists(target);
      if (exists) {
        continue;
      }
      await this.wait(config.interval);
      while (true) {
        const { exists } = await this.fs.base.exists(target);
        if (exists) {
          break;
        }
        status = true;
        log({
          message: "Wait for file to be created",
          level: "INFO",
        });
        await this.wait(config.interval);
      }
    }
    return status;
  },
  hooks: {
    on_action: {
      after: "@nikitajs/core/lib/plugins/metadata/argument_to_config",
      handler: function ({ config }) {
        if (typeof config.target === "string") {
          return (config.target = [config.target]);
        }
      },
    },
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
