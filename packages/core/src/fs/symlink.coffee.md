
# `nikita.fs.symlink`

Delete a name and possibly the file it refers to.

## Source Code

    module.exports = status: false, log: false, handler: ({metadata, options}, callback) ->
      @log message: "Entering fs.symlink", level: 'DEBUG', module: 'nikita/lib/fs/symlink'
      # Normalize options
      options.target = metadata.argument if metadata.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      throw Error "Required Option: the \"source\" option is mandatory" unless options.source
      @system.execute
        cmd: "ln -sf #{options.source} #{options.target}"
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err) ->
        callback err
