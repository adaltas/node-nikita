
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

    module.exports = status: false, handler: ({options}, callback) ->
      @log message: "Entering fs.mkdir", level: 'DEBUG', module: 'nikita/lib/fs/mkdir'
      # Normalize options
      options.target = options.argument if options.argument?
      # Validate parameters
      throw Error "Missing target: #{JSON.stringify options.target}" unless options.target
      cmd = if options.uid or options.gid then 'install ' else 'mkdir '
      if options.mode
        options.mode = options.mode.toString(8).substr(-4) if typeof options.mode is 'number'
        cmd += "-m '#{options.mode}' "
      cmd += " --owner #{options.uid} " if options.uid
      cmd += " --group #{options.gid} " if options.gid
      cmd +=  if options.uid or options.gid then " -d #{options.target}" else "#{options.target}"
      @system.execute
        cmd: cmd
        sudo: options.sudo
        bash: options.bash
        arch_chroot: options.arch_chroot
      , (err) ->
        callback err
