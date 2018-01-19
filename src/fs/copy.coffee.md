
# `nikita.fs.copy(options, callback)`

Change permissions of a file.

## Source Code

    module.exports = status: false, handler: (options, callback) ->
      options.log message: "Entering fs.copy", level: 'DEBUG', module: 'nikita/lib/fs/copy'
      # Normalize options
      options.target = options.argument if options.argument?
      # Validate options
      throw Error "Missing target: #{JSON.stringify options.target}" unless options.target
      throw Error "Missing source: #{JSON.stringify options.source}" unless options.source
      @system.execute
        cmd: """
        [ ! -d `dirname "#{options.target}"` ] && exit 2
        cp #{options.source} #{options.target}
        """
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err) ->
        if err?.code is 2
          err.code = 'ENOENT'
          err.errno = -2
          err.syscall = 'open'
          err.path = options.target
          err.message = "Invalid Target: no such file or directory, open #{JSON.stringify options.target}"
        callback err
