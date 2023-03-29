
// Dependencies
const definitions = require('./schema.json');

// Action
module.exports = {
  handler: async function({config}) {
    try {
      await this.fs.base.stat({
        target: config.target,
        dereference: true
      });
      return {
        exists: true,
        target: config.target
      };
    } catch (error) {
      if (error.code === 'NIKITA_FS_STAT_TARGET_ENOENT') {
        return {
          exists: false,
          target: config.target
        };
      } else {
        throw error;
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
