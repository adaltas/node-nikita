
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

    module.exports = (options, callback) ->
      options.log message: "Entering copy", level: 'DEBUG', module: 'nikita/lib/system/copy'
      # Validate parameters
      return callback Error 'Missing source' unless options.source
      return callback Error 'Missing target' unless options.target
      # Cancel action if target exists ? really ? no md5 comparaison, strange
      # options.unless_exists = options.target if options.unless_exists is true
      # Start real work
      modified = false
      srcStat = null
      dstStat = null
      options.log message: "Stat source file", level: 'DEBUG', module: 'nikita/lib/system/copy'
      fs.stat options.ssh, options.source, (err, stat) ->
        # Source must exists
        return callback err if err
        srcStat = stat
        options.log message: "Stat target file", level: 'DEBUG', module: 'nikita/lib/system/copy'
        fs.stat options.ssh, options.target, (err, stat) ->
          return callback err if err and err.code isnt 'ENOENT'
          dstStat = stat
          sourceEndWithSlash = options.source.lastIndexOf('/') is options.source.length - 1
          if srcStat.isDirectory() and dstStat and not sourceEndWithSlash
            options.target = path.resolve options.target, path.basename options.source
          if srcStat.isDirectory()
          then do_directory options.source, (err) -> callback err, modified
          else do_copy options.source, (err) -> callback err, modified
      # Copy a directory
      do_directory = (dir, callback) ->
        options.log message: "Source is a directory", level: 'INFO', module: 'nikita/lib/system/copy'
        glob options.ssh, "#{dir}/**", dot: true, (err, files) ->
          return callback err if err
          each files
          .call (file, callback) ->
            do_copy file, callback
          .then callback
      do_copy = (source, callback) =>
        if srcStat.isDirectory()
          target = path.resolve options.target, path.relative options.source, source
        else if not srcStat.isDirectory() and dstStat?.isDirectory()
          target = path.resolve options.target, path.basename source
        else
          target = options.target
        fs.stat options.ssh, source, (err, stat) ->
          return callback err if err
          if stat.isDirectory()
          then do_copy_dir source, target
          else do_copy_file source, target
        do_copy_dir = (source, target) ->
          options.log message: "Create directory #{target}", level: 'WARN', module: 'nikita/lib/system/copy'
          # todo, add permission
          fs.mkdir options.ssh, target, (err) ->
            return callback() if err?.code is 'EEXIST'
            return callback err if err
            modified = true
            do_end()
        # Copy a file
        do_copy_file = (source, target) ->
          misc.file.compare options.ssh, [source, target], (err, md5) ->
            # Destination may not exists
            return callback err if err and err.message.indexOf('Does not exist') isnt 0
            # Files are the same, we can skip copying
            return do_chown_chmod target if md5
            options.log message: "Copy file from #{source} into #{target}", level: 'WARN', module: 'nikita/lib/system/copy'
            misc.file.copyFile options.ssh, source, target, (err) ->
              return callback err if err
              modified = true
              do_chown_chmod target
        do_chown_chmod = (target) =>
          @system.chown
            target: target
            uid: options.uid
            gid: options.gid
            if: options.uid? or options.gid?
          @system.chmod
            target: target
            mode: options.mode
            if: options.mode?
          @then (err, status) ->
            return callback err if err
            modified = true if status
            do_end()
        do_end = ->
          options.log message: "File #{source} copied", level: 'DEBUG', module: 'nikita/lib/system/copy'
          callback null, modified

## Dependencies

    fs = require 'ssh2-fs'
    path = require 'path'
    each = require 'each'
    misc = require '../misc'
    glob = require '../misc/glob'
