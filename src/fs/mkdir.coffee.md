
# `nikita.fs.mkdir(options, callback)`

Make directories.

## Source Code

    module.exports = status: false, handler: (options, callback) ->
      options.log message: "Entering fs.mkdir", level: 'DEBUG', module: 'nikita/lib/fs/mkdir'
      # Validate parameters
      throw Error "Missing target: #{JSON.stringify options.target}" unless options.target
      if options.mode
        options.mode = options.mode.toString(8).substr(-4) if typeof options.mode is 'number'
        mode = "-m '#{options.mode}'"
      else
        mode = ''
      @system.execute
        cmd: """
        mkdir #{mode} #{options.target}
        """
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err) ->
        callback err
