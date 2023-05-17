// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    if (!!config.pre_stop) {
      await this.call(config, config.pre_stop);
    }
    // Stop containers
    for (const containerName in config.containers) {
      await this.lxc.stop({
        $header: `Container ${containerName} : stop`,
        container: containerName,
        wait: config.wait
      });
    }
    return {};
  },
  hooks: {
    on_action: {
      before: ['@nikitajs/core/src/plugins/metadata/schema'],
      handler: function({config}) {
        for (const name in config.containers) {
          config.containers[name].container = name;
        }
      }
    }
  },
  metadata: {
    definitions: definitions
  }
};
