
// Dependencies
import utils from '@nikitajs/core/utils';
import { escapeshellarg as esa } from "@nikitajs/core/utils/string";
import definitions from "./schema.json" assert { type: "json" };

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
export default {
  handler: async function({
    config,
    tools: {log}
  }) {
    try {
      await this.execute({
        command: [`[ ! -d ${esa(config.target)} ] && exit 2`, !config.recursive ? `rmdir ${esa(config.target)}` : `rm -R ${esa(config.target)}`].join('\n')
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
