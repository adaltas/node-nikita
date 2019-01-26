
# `nikita.system.copy`

Copy a file. The behavior is similar to the one of the `cp`
Unix utility. Copying a file over an existing file will
overwrite it.

## Options

* `gid`   
  Group name or id who owns the file.   
* `mode`   
  Permissions of the file or the parent directory.   
* `parent` (boolean|object)   
  Create parent directory with provided attributes if an object or default 
  system options if "true", supported attributes include 'mode', 'uid', 'gid', 
  'size', 'atime', and 'mtime'.   
* `preserve`   
  Preserve file ownerships and permissions, default to "false".
* `source`   
  The file or directory to copy.   
* `source_stats`   
  Short-circuit to prevent source stat retrieval if already at our disposal.   
* `target`   
  Where the file or directory is copied.   
* `target_stats`   
  Short-circuit to prevent target stat retrieval if already at our disposal.   
* `uid`   
  User name or id who owns the file.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if copied file was created or modified.   

## Todo

* Apply permissions to directories
* Handle symlinks
* Handle globing
* Preserve permissions if `mode` is `true`

## Example

```js
require('nikita').system.copy({
  source: '/etc/passwd',
  target: '/etc/passwd.bck',
  uid: 'my_user'
  gid: 'my_group'
  mode: '0755'
}, function(err, {status}){
  console.info(err ? err.message : 'File was copied: ' + status);
});
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering copy", level: 'DEBUG', module: 'nikita/lib/system/copy'
      # SSH connection
      ssh = @ssh options.ssh

Validate parameters.

      options.uid ?= null
      options.uid = parseInt options.uid if typeof options.uid is 'string' and not isNaN parseInt options.uid
      options.gid ?= null
      options.gid = parseInt options.gid if typeof options.gid is 'string' and not isNaN parseInt options.uid
      options.preserve ?= false
      options.parent ?= {}
      options.parent = {} if options.parent is true
      throw Error 'Missing source' unless options.source
      throw Error 'Missing target' unless options.target

Retrieve stats information about the source unless provided through the "source_stats" option.

      @call ({}, callback) ->
        if options.source_stats
          @log message: "Source Stats: using short circuit", level: 'DEBUG', module: 'nikita/lib/system/copy'
          return callback()
        @log message: "Stats source file #{options.source}", level: 'DEBUG', module: 'nikita/lib/system/copy'
        @fs.stat ssh: options.ssh, target: options.source, (err, {stats}) ->
          return callback err if err
          options.source_stats = stats unless err
          callback()

Retrieve stat information about the traget unless provided through the "target_stats" option.

      @call ({}, callback) ->
        if options.target_stats
          @log message: "Target Stats: using short circuit", level: 'DEBUG', module: 'nikita/lib/system/copy'
          return callback()
        @log message: "Stats target file #{options.target}", level: 'DEBUG', module: 'nikita/lib/system/copy'
        @fs.stat ssh: options.ssh, target: options.target, (err, {stats}) ->
          # Note, target file doesnt necessarily exist
          return callback err if err and err.code isnt 'ENOENT'
          options.target_stats = stats if stats
          callback()

Create target parent directory if target does not exists and if the "parent"
options is set to "true" (default) or as an object.

      @system.mkdir
        if: !!options.parent
        unless: options.target_stats
        target: path.dirname options.target
      , options.parent
        
Stop here if source is a directory. We traverse all its children
Recursively, calling either `system.mkdir` or `system.copy`.

Like with the Unix `cp` command, ending slash matters if the target directory 
exists. Let's consider a source directory "/tmp/a_source" and a target directory
"/tmp/a_target". Without an ending slash , the directory "/tmp/a_source" is 
copied into "/tmp/a_target/a_source". With an ending slash, all the files
present inside "/tmp/a_source" are copied inside "/tmp/a_target".

      @call ({}, callback) ->
        return callback() unless misc.stats.isDirectory options.source_stats.mode
        sourceEndWithSlash = options.source.lastIndexOf('/') is options.source.length - 1
        if options.target_stats and not sourceEndWithSlash
          options.target = path.resolve options.target, path.basename options.source
        @log message: "Source is a directory", level: 'INFO', module: 'nikita/lib/system/copy'
        @file.glob "#{options.source}/**", dot: true, (err, {files}) =>
          return callback err if err
          for source in files then do (source) =>
            target = path.resolve options.target, path.relative options.source, source
            @fs.stat ssh: options.ssh, target: source, (err, {stats}) =>
              uid = options.uid
              uid ?= stats.uid if options.preserve
              gid = options.gid
              gid ?= stats.gid if options.preserve
              mode = options.mode
              mode ?= stats.mode if options.preserve
              if misc.stats.isDirectory stats.mode
                @system.mkdir
                  target: target
                  uid: uid
                  gid: gid
                  mode: mode
              else
                @system.copy
                  target: target
                  source: source
                  source_stat: stats
                  uid: uid
                  gid: gid
                  mode: mode
        @next (err, {status}) -> callback err, {status: status, end: true}
      , (err, {end}) ->
        @end() if not err and end

If source is a file and target is a directory, then transform
target into a file.

      @call ->
        return unless options.target_stats and misc.stats.isDirectory options.target_stats.mode
        options.target = path.resolve options.target, path.basename options.source

Copy the file if content doesn't match.

      @call ->
        hash_source = hash_target = null
        @file.hash options.source, (err, {hash}) ->
          throw err if err
          hash_source = hash
        @file.hash options.target, relax: true, (err, {hash}) ->
          throw err if err and not err.code is 'ENOENT'
          hash_target = hash
        @call ({}, callback) ->
          match = hash_source is hash_target
          @log if match
          then message: "Hash matches as '#{hash_source}'", level: 'INFO', module: 'nikita/lib/file/download' 
          else message: "Hash dont match, source is '#{hash_source}' and target is '#{hash_target}'", level: 'WARN', module: 'nikita/lib/file/download'
          callback null, not match
        @call
          if: -> @status -1
        , ->
          # Copy a file
          @log message: "Copy file from #{options.source} into #{options.target}", level: 'DEBUG', module: 'nikita/lib/system/copy'
          @fs.copy
            source: options.source
            target: options.target
          , (err, status) ->
            @log message: "File copied from #{options.source} into #{options.target}", level: 'INFO', module: 'nikita/lib/system/copy' if status

File ownership and permissions

      @call ->
        options.uid ?= options.source_stats.uid if options.preserve
        options.gid ?= options.source_stats.gid if options.preserve
        options.mode ?= options.source_stats.mode if options.preserve
        @system.chown
          target: options.target
          stats: options.target_stats
          uid: options.uid
          gid: options.gid
          if: options.uid? or options.gid?
        @system.chmod
          target: options.target
          stats: options.target_stats
          mode: options.mode
          if: options.mode?

## Dependencies

    path = require 'path'
    misc = require '../misc'
