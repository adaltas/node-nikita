
# `nikita.fs.lstat`

Retrieve file information. If path is a symbolic link, then the link itself is
stated, not the file that it refers to.

## Source Code

    module.exports = status: false, log: false, handler: ({metadata, options}, callback) ->
      @log message: "Entering fs.lstat", level: 'DEBUG', module: 'nikita/lib/fs/lstat'
      # Normalize options
      options.target = metadata.argument if metadata.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      @fs.stat
        target: options.target
        dereference: false
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , callback
