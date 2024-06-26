// Dependencies
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function({config}) {
    // Pre hook
    if (!!config.pre_delete) {
      await this.call(config, config.pre_delete);
    }
    // Containers removal
    for (const name in config.containers) {
      await this.incus.delete({
        $header: `Container ${name} : delete`,
        container: name,
        force: config.force
      });
    }
    // Networks removal
    for (const name in config.networks) {
      await this.incus.network.delete({
        $header: `Network ${name} : delete`,
        network: name
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
