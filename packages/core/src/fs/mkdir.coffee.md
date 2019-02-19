
# `nikita.fs.mkdir`

Make directories.

## Options

* `uid`   
  Unix user id.   
* `gid`   
  Unix group id.   
* `mode`   
  Default to "0755".   
* `directory`   
  Path or array of paths.   
* `target`   
  Alias for `directory`. 

## Source Code

    module.exports = status: false, log: false, handler: ({options}, callback) ->
      @log message: "Entering fs.mkdir", level: 'DEBUG', module: 'nikita/lib/fs/mkdir'
      # Normalize options
      options.target = options.argument if options.argument?
      # Validate parameters
      throw Error "Required Option: target is required, got #{JSON.stringify options.target}" unless options.target
      options.mode = options.mode.toString(8).substr(-4) if typeof options.mode is 'number'
      @system.execute
        cmd: [
          if options.uid or options.gid then 'install' else 'mkdir'
          "-m '#{options.mode}'" if options.mode
          "-o #{options.uid}" if options.uid
          "-g #{options.gid}" if options.gid
          if options.uid or options.gid then " -d #{options.target}" else "#{options.target}"
        ].join ' '
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err) ->
        callback err
