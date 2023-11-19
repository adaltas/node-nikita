
// ## Dependencies
import dedent from 'dedent';
import utils from '@nikitajs/core/utils';
import definitions from "./schema.json" assert { type: "json" };

const errors = {
  NIKITA_FS_UNLINK_ENOENT: function({config}) {
    return utils.error('NIKITA_FS_UNLINK_ENOENT', [
      'the file to remove does not exists,',
      `got ${JSON.stringify(config.target)}`
    ]);
  },
  NIKITA_FS_UNLINK_EPERM: function({config}) {
    return utils.error('NIKITA_FS_UNLINK_EPERM', [
      'you do not have the permission to remove the file,',
      `got ${JSON.stringify(config.target)}`
    ]);
  }
};

// Action
export default {
  handler: async function({config}) {
    try {
      // `! -e`: file does not exist
      // `! -L && -d`: file is not a symlink and is a directory,
      // Note, in preview line, the `! -L` symlink test is required
      // because the `-d` operator follows the test if the file is a symlink
      await this.execute(dedent`
        [ ! -e '${config.target}' ] && exit 2
        [ ! -L '${config.target}' ] && [ -d '${config.target}' ] && exit 3
        unlink '${config.target}'
      `);
    } catch (error) {
      switch (error.exit_code) {
        case 2:
          throw errors.NIKITA_FS_UNLINK_ENOENT({
            config: config
          });
        case 3:
          throw errors.NIKITA_FS_UNLINK_EPERM({
            config: config
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
