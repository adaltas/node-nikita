
# `nikita.fs.readlink(options, callback)`

Delete a name and possibly the file it refers to.

## Source Code

    module.exports = status: false, handler: (options, callback) ->
      options.log message: "Entering fs.readlink", level: 'DEBUG', module: 'nikita/lib/fs/readlink'
      # Normalize options
      options.target = options.argument if options.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      @system.execute
        cmd: "readlink #{options.target}"
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err, _, stdout) ->
        callback err, stdout.trim()
