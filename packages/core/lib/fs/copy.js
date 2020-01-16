// Generated by CoffeeScript 2.5.0
// # `nikita.fs.copy`

// Change permissions of a file.

// ## Source Code
module.exports = {
  status: false,
  log: false,
  handler: function({metadata, options}, callback) {
    this.log({
      message: "Entering fs.copy",
      level: 'DEBUG',
      module: 'nikita/lib/fs/copy'
    });
    if (metadata.argument != null) {
      // Normalize options
      options.target = metadata.argument;
    }
    if (!options.target) {
      // Validate options
      throw Error(`Missing target: ${JSON.stringify(options.target)}`);
    }
    if (!options.source) {
      throw Error(`Missing source: ${JSON.stringify(options.source)}`);
    }
    return this.system.execute({
      cmd: `[ ! -d \`dirname "${options.target}"\` ] && exit 2
cp ${options.source} ${options.target}`,
      sudo: options.sudo,
      bash: options.bash,
      arch_chroot: options.arch_chroot
    }, function(err) {
      if ((err != null ? err.code : void 0) === 2) {
        err.code = 'ENOENT';
        err.errno = -2;
        err.syscall = 'open';
        err.path = options.target;
        err.message = `Invalid Target: no such file or directory, open ${JSON.stringify(options.target)}`;
      }
      return callback(err);
    });
  }
};
