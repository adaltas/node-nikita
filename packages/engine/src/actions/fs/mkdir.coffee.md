
# `nikita.system.mkdir`

Recursively create a directory. The behavior is similar to the Unix command
`mkdir -p`. It supports an alternative syntax where options is simply the path
of the directory to create.

## Options

* `cwd`   
  Current working directory for relative paths.   
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
* `exclude`   
  Regular expression.   
* `parent` (boolean|object)   
  Create parent directory with provided attributes if an object or default 
  system options if "true", supported attributes include 'mode', 'uid', 'gid', 
  'size', 'atime', and 'mtime'.   
* `source`   
  Alias for `directory`.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if directory was created or modified.   

## Simple usage

```js
require('nikita')
.system.mkdir('./some/dir', function(err, {status}){
  console.info(err ? err.message : "Directory created: " + status);
});
```

## Advanced usage

```js
require('nikita')
.system.mkdir({
  ssh: ssh,
  target: './some/dir',
  uid: 'a_user',
  gid: 'a_group'
  mode: 0o0777 // or '777'
}, function(err, {status}){
  console.info(err ? err.message : 'Directory created: ' + status);
});
```

## Source Code

    module.exports = ({metadata, options}, callback) ->
      @log message: "Entering mkdir", level: 'DEBUG', module: 'nikita/lib/system/mkdir'
      # SSH connection
      ssh = @ssh options.ssh
      p = if ssh then path.posix else path
      # logs for children
      metadata.log = if typeof metadata.log is 'boolean' then metadata.log else false
      # Validate options
      options.target = metadata.argument if metadata.argument?
      options.directory ?= options.target
      options.directory ?= options.source
      return callback Error 'Missing target option' unless options.directory?
      options.cwd = process.cwd() if not ssh and (options.cwd is true or not options.cwd)
      options.directory = [options.directory] unless Array.isArray options.directory
      options.parent = {} if options.parent is true
      for directory, i in options.directory
        # Note: path.resolve also normalize
        options.directory[i] = directory = if options.cwd then p.resolve options.cwd, directory else p.normalize directory
        if ssh
          throw Error "Non Absolute Path: target is #{JSON.stringify directory}, SSH requires absolute paths, you must provide an absolute path in the target or the cwd option" unless p.isAbsolute directory
      # State
      state = status: false
      each options.directory
      .call (directory, callback) =>
        # first, we need to find which directory need to be created
        # @log message: "Creating directory '#{directory}'", level: 'DEBUG', module: 'nikita/lib/system/mkdir'
        do_stats = =>
          end = false
          dirs = []
          # Create directory and its parent directories
          directories = directory.split('/')
          directories.shift() # first element is empty with absolute path
          directories.pop() if directories[directories.length-1] is ''
          directories = for i in [0...directories.length]
            '/' + directories.slice(0, directories.length - i).join '/'
          each(directories)
          .call (directory, i, next) =>
            @log message: "Stat '#{directory}'", level: 'DEBUG', module: 'nikita/lib/system/mkdir'
            @fs.base.stat target: directory, log: metadata.log, (err, {stats}) ->
              if err?.code is 'ENOENT' # if the directory is not yet created
                directory.stats = stats
                dirs.push directory
                if i is directories.length - 1
                then return do_create dirs
                else return next()
              if misc.stats.isDirectory stats.mode
                end = true
                return if i is 0 then do_update(stats) else do_create dirs
              if err
                return next err
              else # a file or symlink exists at this location
                return next Error "Invalid Directory: path #{JSON.stringify directory} exists but is not a directory, got \"#{misc.stats.type stats.mode}\" type"
          .next callback
        do_create = (directories) =>
          each directories.reverse()
          .call (directory, i, callback) =>
            # Directory name contains variables
            # eg /\${/ on './var/cache/${user}' creates './var/cache/'
            if options.exclude? and options.exclude instanceof RegExp
              return callback() if options.exclude.test path.basename directory
            @log message: "Create directory \"#{directory}\"", level: 'DEBUG', module: 'nikita/lib/system/mkdir' # unless directory is options.directory
            opts = {}
            for attr in ['mode', 'uid', 'gid', 'size', 'atime', 'mtime']
              val = if i is directories.length - 1 then options[attr] else options.parent?[attr]
              opts[attr] = val if val?
            @fs.base.mkdir target: directory, log: metadata.log, opts, (err) ->
              return callback err if err
              @log message: "Directory \"#{directory}\" created ", level: 'INFO', module: 'nikita/lib/system/mkdir'
              state.status = true
              callback()
          .next (err) ->
            return callback err if err
            callback()
        do_update = (stats) =>
          @log message: "Directory already exists", level: 'INFO', module: 'nikita/lib/system/mkdir'
          @system.chown
            target: directory
            stats: stats
            uid: options.uid
            gid: options.gid
            if: options.uid? or options.gid?
          @system.chmod
            target: directory
            stats: stats
            mode: options.mode
            if: options.mode?
          @next (err, {status}) ->
            return callback err if err
            state.status = true if status
            callback()
        do_stats()
      .next (err) ->
        callback err, state.status

## Dependencies

    path = require('path').posix
    each = require 'each'
    misc = require '../misc'
