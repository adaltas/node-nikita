
// Dependencies
const utils = require('../../../../utils');
const definitions = require('./schema.json');

const {escapeshellarg} = utils.string;

const errors = {
  NIKITA_FS_RMDIR_TARGET_ENOENT: ({config, error}) =>
    utils.error('NIKITA_FS_RMDIR_TARGET_ENOENT', ['fail to remove a directory, target is not a directory,', `got ${JSON.stringify(config.target)}`], {
      exit_code: error.exit_code,
      errno: -2,
      syscall: 'rmdir',
      path: config.target
    })
};

// Action
module.exports = {
  handler: async function({
    config,
    tools: {log}
  }) {
    try {
      await this.execute({
        command: [`[ ! -d ${escapeshellarg(config.target)} ] && exit 2`, !config.recursive ? `rmdir ${escapeshellarg(config.target)}` : `rm -R ${escapeshellarg(config.target)}`].join('\n')
      });
      log({
        message: "Directory successfully removed",
        level: 'INFO'
      });
    } catch (error) {
      if (error.exit_code === 2) {
        error = errors.NIKITA_FS_RMDIR_TARGET_ENOENT({
          config: config,
          error: error
        });
      }
      throw error;
    }
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  }
};
