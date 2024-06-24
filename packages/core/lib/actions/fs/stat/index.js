
// Dependencies
import dedent from 'dedent';
import utils from '@nikitajs/core/utils';
import { escapeshellarg as esa } from "@nikitajs/utils/string";
import definitions from "./schema.json" with { type: "json" };

const errors = {
  NIKITA_FS_STAT_TARGET_ENOENT: ({config, error}) =>
    utils.error('NIKITA_FS_STAT_TARGET_ENOENT', ['failed to stat the target, no file exists for target,', `got ${JSON.stringify(config.target)}`], {
      exit_code: error.exit_code,
      errno: -2,
      syscall: 'rmdir',
      path: config.target
    })
};

// Action
export default {
  handler: async function({config}) {
    // Normalize configuration
    // config.dereference ??= true;
    const dereference = config.dereference ? "-L" : "";
    const {stdout} = await this.execute({
      command: dedent`
        [ ! -e ${config.target} ] && exit 3
        if [ -d /private ]; then
          stat ${dereference} -f '%Xp|%u|%g|%z|%a|%m' ${esa(config.target)} # MacOS
        else
          stat ${dereference} -c '%f|%u|%g|%s|%X|%Y' ${esa(config.target)} # Linux
        fi
      `,
      trim: true
    }).catch( error => {
      if (error.exit_code === 3) {
        throw errors.NIKITA_FS_STAT_TARGET_ENOENT({
          config: config,
          error: error
        });
      }
      throw error;
    });
    const [rawmodehex, uid, gid, size, atime, mtime] = stdout.split("|");
    return {
      stats: {
        mode: parseInt(rawmodehex, 16), // dont know why `rawmodehex` was prefixed by `"0xa1ed"`
        uid: parseInt(uid, 10),
        gid: parseInt(gid, 10),
        size: parseInt(size, 10),
        atime: parseInt(atime, 10),
        mtime: parseInt(mtime, 10),
      },
    };
  },
  metadata: {
    argument_to_config: 'target',
    log: false,
    raw_output: true,
    definitions: definitions
  },
};
