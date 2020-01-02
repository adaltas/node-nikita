
# `nikita.fs.rename`

Change the name or location of a file.

## Source Code

    module.exports = status: false, log: false, handler: ({metadata, options}, callback) ->
      @log message: "Entering fs.rename", level: 'DEBUG', module: 'nikita/lib/fs/rename'
      # Normalize options
      options.target = metadata.argument if metadata.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      throw Error "Required Option: the \"source\" option is mandatory" unless options.source
      @system.execute
        cmd: "mv #{options.source} #{options.target}"
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err, {stdout}) ->
        callback err, stdout.trim()
