
// Dependencies
const {Dirent, constants} = require('fs');
const dedent = require('dedent');
const utils = require('../../../../utils');
const definitions = require('./schema.json');

const errors = {
  NIKITA_FS_READDIR_TARGET_ENOENT: ({config, error}) =>
    utils.error('NIKITA_FS_READDIR_TARGET_ENOENT', ['fail to read a directory, target is not a directory,', `got ${JSON.stringify(config.target)}`], {
      exit_code: error.exit_code,
      errno: -2,
      syscall: 'rmdir',
      path: config.target
    })
}

// Action
module.exports = {
  handler: async function({config}) {
    // Note: -w work on macos, not on linux, it force raw printing of
    // non-printable characters. This is the default when output is not to a
    // terminal.
    const opts = [
      '1', // (The numeric digit ``one''.)  Force output to be one entry per line.  This is the default when output is not to a terminal.
      'a', // Include directory entries whose names begin with a dot (.)
      config.extended ? 'n' : void 0, // Display user and group IDs numerically, rather than converting to a user or group name in a long (-l) output.  This option turns on the -l option.
      config.extended ? 'l' : void 0
    ].join('');
    try {
      // List the directory
      const {stdout} = await this.execute({
        command: dedent`
          [ ! -d '${config.target}' ] && exit 2
          ls -${opts} ${config.target}
        `
      });
      return {
        // Convert the output into a `files` array
        files: utils.string
          .lines(stdout)
          .filter( (line, i) =>
            !config.extended || i !== 0 // First line in extended mode
          ).filter( (line) =>
            line !== '' // Empty lines
          ).map(function(line, i) {
            if (!config.extended) {
              return {
                name: line
              };
            } else {
              const [, perm, , name] = /^(.+?)\s+.*?(\d+:\d+)\s+(.+)$/.exec(line);
              return {
                name: name,
                type:
                  perm[0] === 'b' && constants.UV_DIRENT_BLOCK  || // Block special file
                  perm[0] === 'c' && constants.UV_DIRENT_CHAR   || // Character special file
                  perm[0] === 'd' && constants.UV_DIRENT_DIR    || // Directory
                  perm[0] === 'l' && constants.UV_DIRENT_LINK   || // Symbolic link
                  perm[0] === 's' && constants.UV_DIRENT_SOCKET || // Socket link
                  perm[0] === 'p' && constants.UV_DIRENT_FIFO   || // FIFO
                  constants.UV_DIRENT_FILE                         // Regular file
              };
            }
        }).filter( ({name}) =>
          name !== '' && name !== '.' && name !== '..'
        ).map((file) =>
          config.extended
            // 20230527, Node.js 20 introduce a `path` property with the parent dir,
            // We might do sth about it such as:
            // ? (function () {
            //   // Return a new DirEnt object
            //   const dirent = new Dirent(file.name, file.type);
            //   if (!dirent.path) {
            //     dirent.path = config.target;
            //   }
            //   return dirent;
            // })()
            ? new Dirent(file.name, file.type)
            : file.name
        )
      };
    } catch (error) {
      if (error.exit_code === 2) {
        throw errors.NIKITA_FS_READDIR_TARGET_ENOENT({
          config: config,
          error: error
        });
      } else {
        throw error;
      }
      throw error;
    }
  },
  hooks: {
    on_action: function({config, metadata}) {
      if (config.withFileTypes != null) {
        return config.extended != null ? config.extended : config.extended = config.withFileTypes;
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
