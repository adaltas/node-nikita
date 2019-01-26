
# `nikita.fs.chown`

Change ownership of a file.

## Source Code

    module.exports = status: false, log: false, handler: ({options}, callback) ->
      @log message: "Entering fs.chown", level: 'DEBUG', module: 'nikita/lib/fs/chown'
      # Normalize options
      options.target = options.argument if options.argument?
      options.uid = null if options.uid is false
      options.gid = null if options.gid is false
      # Validate options
      throw Error "Missing target: #{JSON.stringify options.target}" unless options.target
      throw Error "Missing one of uid or gid option" unless options.uid? or options.gid?
      @system.execute
        if: options.uid? or options.gid?
        cmd: """
        [ ! -z '#{if options.uid? then options.uid else ''}' ] && chown #{options.uid} #{options.target}
        [ ! -z '#{if options.gid? then options.gid else ''}' ] && chgrp #{options.gid} #{options.target}
        """
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err) ->
       callback err
