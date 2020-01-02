
# `nikita.fs.unlink`

Delete a name and possibly the file it refers to.

## Source Code

    module.exports = status: false, log: false, handler: ({metadata, options}, callback) ->
      @log message: "Entering fs.unlink", level: 'DEBUG', module: 'nikita/lib/fs/unlink'
      # Normalize options
      options.target = metadata.argument if metadata.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      @system.execute
        cmd: "unlink #{options.target}"
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err) ->
       callback err
