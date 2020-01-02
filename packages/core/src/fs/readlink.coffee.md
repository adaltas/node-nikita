
# `nikita.fs.readlink`

Delete a name and possibly the file it refers to.

## Source Code

    module.exports = status: false, log: false, handler: ({metadata, options}, callback) ->
      @log message: "Entering fs.readlink", level: 'DEBUG', module: 'nikita/lib/fs/readlink'
      # Normalize options
      options.target = metadata.argument if metadata.argument?
      throw Error "Required Option: the \"target\" option is mandatory" unless options.target
      @system.execute
        cmd: "readlink #{options.target}"
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err, {stdout}) ->
        callback err, target: stdout.trim()
