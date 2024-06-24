// Dependencies
import utils from '@nikitajs/core/utils';
import definitions from "./schema.json" with { type: "json" };

// Action
export default {
  handler: async function ({ config, tools: { log } }) {
    let stats;
    if (config.stats) {
      stats = config.stats;
    } else {
      ({ stats } = await this.fs.stat(config.target));
    }
    // Detect changes
    if (utils.mode.compare(stats.mode, config.mode)) {
      log({
        message: `Identical permissions \"${config.mode.toString(8)}\" on \"${
          config.target
        }\"`,
        level: "INFO",
      });
      return false;
    }
    // Apply changes
    await this.fs.base.chmod({
      target: config.target,
      mode: config.mode,
    });
    log({
      message: [
        `Permissions changed`,
        `from "${stats.mode.toString(8)}"`,
        `to "${config.mode.toString(8)}"`,
        `on "${config.target}"`,
      ].join(' '),
      level: "WARN",
    });
    return true;
  },
  metadata: {
    argument_to_config: "target",
    definitions: definitions,
  },
};
