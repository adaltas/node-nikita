
# `nikita.fs.lstat(options, callback)`

Retrieve file information. If path is a symbolic link, then the link itself is
stat-ed, not the file that it refers to.

## Source Code

    module.exports = status: false, handler: (options, callback) ->
      options.log message: "Entering fs.lstat", level: 'DEBUG', module: 'nikita/lib/fs/lstat'
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      @fs.stat
        target: options.target
        dereference: false
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , callback
