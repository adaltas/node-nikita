
# `nikita.fs.lstat(options, callback)`

Retrieve file information. If path is a symbolic link, then the link itself is
stat-ed, not the file that it refers to.

## Source Code

    module.exports = status: false, handler: (options, callback) ->
      @log message: "Entering fs.exists", level: 'DEBUG', module: 'nikita/lib/fs/exists'
      # Normalize options
      options.target = options.argument if options.argument?
      @fs.stat
        target: options.target
        dereference: true
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
        relax: true
      , (err) ->
        callback null, not err
