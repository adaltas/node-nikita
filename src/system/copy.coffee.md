
# `nikita.system.copy(options, [callback])`

Copy a file. The behavior is similar to the one of the `cp`
Unix utility. Copying a file over an existing file will
overwrite it.

## Options

* `gid`   
  Group name or id who owns the file.   
* `mode`   
  Permissions of the file or the parent directory.   
* `source`   
  The file or directory to copy.   
* `target`   
  Where the file or directory is copied.   
* `uid`   
  User name or id who owns the file.   
* `unless_exists`   
  Equals target if true.   

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
}, function(err, status){
  console.log(err ? err.message : 'File was copied: ' + status);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering copy", level: 'DEBUG', module: 'nikita/lib/system/copy'

Validate parameters.

      throw Error 'Missing source' unless options.source
      throw Error 'Missing target' unless options.target

Retrieve stat information about the source unless provided through the "source_stat" option.

      @call (_, callback) ->
        if options.source_stat
          options.log message: "Source Stat: using short circuit", level: 'DEBUG', module: 'nikita/lib/system/copy'
          return callback()
        options.log message: "Stat source file #{options.source}", level: 'DEBUG', module: 'nikita/lib/system/copy'
        fs.stat options.ssh, options.source, (err, stat) =>
          return callback err if err
          options.source_stat = stat unless err
          callback()

Retrieve stat information about the traget unless provided through the "target_stat" option.

      @call (_, callback) ->
        if options.target_stat
          options.log message: "Target Stat: using short circuit", level: 'DEBUG', module: 'nikita/lib/system/copy'
          return callback()
        options.log message: "Stat target file #{options.target}", level: 'DEBUG', module: 'nikita/lib/system/copy'
        fs.stat options.ssh, options.target, (err, stat) =>
          # Note, target file doesnt necessarily exist
          return callback err if err and err.code isnt 'ENOENT'
          options.target_stat = stat
          callback()

Stop here if source is a directory. We traverse all its children
Recursively, calling either `system.mkdir` or `system.copy`.

Like with the Unix `cp` command, ending slash matters if the target directory 
exists. Let's consider a source directory "/tmp/a_source" and a target directory
"/tmp/a_target". Without an ending slash , the directory "/tmp/a_source" is 
copied into "/tmp/a_target/a_source". With an ending slash, all the files
present inside "/tmp/a_source" are copied inside "/tmp/a_target".

      @call (_, callback) ->
        return callback() unless options.source_stat.isDirectory()
        sourceEndWithSlash = options.source.lastIndexOf('/') is options.source.length - 1
        if options.target_stat and not sourceEndWithSlash
          options.target = path.resolve options.target, path.basename options.source
        options.log message: "Source is a directory", level: 'INFO', module: 'nikita/lib/system/copy'
        @call (_, callback) -> 
          glob options.ssh, "#{options.source}/**", dot: true, (err, sources) =>
            return callback err if err
            for source in sources then do (source) =>
              # target = path.resolve options.target, path.basename source
              target = path.resolve options.target, path.relative options.source, source
              @call (_, callback) ->
                fs.stat options.ssh, source, (err, source_stat) =>
                  if source_stat.isDirectory()
                    # todo: pass uid, gid and mode, use options and default to stat
                    @system.mkdir target
                  else
                    # todo: pass uid, gid and mode, use options and default to stat
                    @system.copy source: source, source_stat: source_stat, target: target
                  @then callback
            @then callback
        @then (err, status) -> callback err, status, true
      , (err, status, end) ->
        @end() if not err and end

If source is a file and target is a directory, then transform
target into a file.

      @call ->
        return unless options.target_stat and options.target_stat.isDirectory()
        options.target = path.resolve options.target, path.basename options.source

Copy the file if content doesnt match.

      @call (_, callback) =>
        # Copy a file
        misc.file.compare options.ssh, [options.source, options.target], (err, md5) ->
          # Destination may not exists
          return callback err if err and err.message.indexOf('Does not exist') isnt 0
          # Files are the same, we can skip copying
          return callback null, false if md5
          options.log message: "Copy file from #{options.source} into #{options.target}", level: 'WARN', module: 'nikita/lib/system/copy'
          misc.file.copyFile options.ssh, options.source, options.target, (err) ->
            callback err, true
      , (err, status) ->
        options.log message: "File #{options.source} copied", level: 'DEBUG', module: 'nikita/lib/system/copy'

File ownership and permissions

      @call ->
        @system.chown
          target: options.target
          uid: options.uid
          gid: options.gid
          if: options.uid? or options.gid?
        @system.chmod
          target: options.target
          mode: options.mode
          if: options.mode?

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    misc = require '../misc'
    glob = require '../misc/glob'
