
# `nikita.system.chmod(options, [callback])`

Change the permissions of a file or directory.

## Options

* `mode`   
  Permissions of the file or the parent directory.   
* `stat` (Stat instance, optional)   
  Pass the Stat object relative to the target file or directory, to be
  used as an optimization.     
* `target`   
  Where the file or directory is copied.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file permissions was created or modified.   

## Example

```js
require('nikita').system.chmod({
  target: '~/my/project',
  mode: 0o755
}, function(err, modified){
  console.log(err ? err.message : 'File was modified: ' + modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      options.log message: "Entering chmod", level: 'DEBUG', module: 'nikita/lib/system/chmod'
      # Validate parameters
      return callback Error "Missing target: #{JSON.stringify options.target}" unless options.target
      return callback Error "Missing option 'mode'" unless options.mode
      do_stat = ->
        # Option 'stat' short-circuit
        return do_chmod options.stat if options.stat
        options.log message: "Stat \"#{options.target}\"", level: 'DEBUG', module: 'nikita/lib/system/chmod'
        fs.stat options.ssh, options.target, (err, stat) ->
          return callback err if err
          do_chmod stat
      do_chmod = (stat) ->
        # Detect changes
        if misc.mode.compare stat.mode, options.mode
          options.log message: "Identical permissions on \"#{options.target}\"", level: 'INFO', module: 'nikita/lib/system/chmod'
          return callback()
        # Apply changes
        fs.chmod options.ssh, options.target, options.mode, (err) ->
          options.log message: "Change permissions from \"#{stat.mode.toString 8}\" to \"#{options.mode.toString 8}\" on \"#{options.target}\"", level: 'WARN', module: 'nikita/lib/system/chmod'
          callback err, true
      do_stat()

## Dependencies

    fs = require 'ssh2-fs'
    misc = require '../misc'
