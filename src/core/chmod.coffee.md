
# `chmod(options, callback)`

Change the permissions of a file or directory.

## Options

*   `destination`   
    Where the file or directory is copied.   
*   `mode`   
    Permissions of the file or the parent directory.   
*   `log`   
    Function called with a log related messages.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stat` (Stat instance, optional)   
    Pass the Stat object relative to the destination file or directory, to be
    used as an optimization.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Number of permissions with modifications.   

## Example

```js
require('mecano').chmod({
  destination: '~/my/project',
  mode: 0o755
}, function(err, modified){
  console.log(err ? err.message : 'File was modified: ' + modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters
      return callback Error "Missing destination: #{JSON.stringify options.destination}" unless options.destination
      return callback Error "Missing option 'mode'" unless options.mode
      do_stat = ->
        # Option 'stat' short-circuit
        return do_chmod options.stat if options.stat
        options.log message: "Stat \"#{options.destination}\"", level: 'DEBUG', module: 'mecano/src/chmod'
        fs.stat options.ssh, options.destination, (err, stat) ->
          return callback err if err
          do_chmod stat
      do_chmod = (stat) ->
        # Detect changes
        if misc.mode.compare stat.mode, options.mode
          options.log message: "Identical permissions on \"#{options.destination}\"", level: 'INFO', module: 'mecano/src/chmod'
          return callback()
        # Apply changes
        fs.chmod options.ssh, options.destination, options.mode, (err) ->
          options.log message: "Change permissions from \"#{stat.mode}\" to \"#{options.mode}\" on \"#{options.destination}\"", level: 'WARN', module: 'mecano/src/chmod'
          callback err, true
      do_stat()

## Dependencies

    fs = require 'ssh2-fs'
    misc = require '../misc'
