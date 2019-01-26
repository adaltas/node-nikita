
# `nikita.fs.chmod`

Change permissions of a file.

## Source Code

    module.exports = status: false, log: false, handler: ({options}, callback) ->
      @log message: "Entering fs.chmod", level: 'DEBUG', module: 'nikita/lib/fs/chmod'
      # Normalize options
      options.target = options.argument if options.argument?
      # Validate options
      throw Error "Missing target: #{JSON.stringify options.target}" unless options.target
      throw Error "Missing option 'mode'" unless options.mode
      options.mode = options.mode.toString(8).substr(-4) if typeof options.mode is 'number'
      @system.execute
        if: options.mode
        cmd: "chmod #{options.mode} #{options.target}"
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err) ->
       callback err
