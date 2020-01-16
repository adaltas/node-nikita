// Generated by CoffeeScript 2.5.0
// # `nikita.fs.mkdir`

// Make directories.

// ## Options

// * `uid`   
//   Unix user id.   
// * `gid`   
//   Unix group id.   
// * `mode`   
//   Default to "0755".   
// * `directory`   
//   Path or array of paths.   
// * `target`   
//   Alias for `directory`. 

// ## Source Code
module.exports = {
  status: false,
  log: false,
  handler: function({metadata, options}, callback) {
    this.log({
      message: "Entering fs.mkdir",
      level: 'DEBUG',
      module: 'nikita/lib/fs/mkdir'
    });
    if (metadata.argument != null) {
      // Normalize options
      options.target = metadata.argument;
    }
    if (!options.target) {
      // Validate parameters
      throw Error(`Required Option: target is required, got ${JSON.stringify(options.target)}`);
    }
    if (typeof options.mode === 'number') {
      options.mode = options.mode.toString(8).substr(-4);
    }
    return this.system.execute({
      cmd: [options.uid || options.gid ? 'install' : 'mkdir', options.mode ? `-m '${options.mode}'` : void 0, options.uid ? `-o ${options.uid}` : void 0, options.gid ? `-g ${options.gid}` : void 0, options.uid || options.gid ? ` -d ${options.target}` : `${options.target}`].join(' '),
      sudo: options.sudo,
      bash: options.bash,
      arch_chroot: options.arch_chroot
    }, function(err) {
      return callback(err);
    });
  }
};
