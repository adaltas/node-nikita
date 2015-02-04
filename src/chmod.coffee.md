
# `chmod(options, [goptions], callback)`

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
      wrap arguments, (options, callback) ->
        # Validate parameters
        return callback Error "Missing destination: #{options.destination}" unless options.destination
        return callback Error "Missing mode: #{options.mode}" unless options.mode
        do_stat = ->
          return do_compare options.stat if options.stat
          options.log? "Mecano `chmod`: stat \"#{options.destination}\""
          fs.stat options.ssh, options.destination, (err, stat) ->
            return callback err if err
            do_compare stat
        do_compare = (stat) ->
          return callback() if misc.mode.compare stat.mode, options.mode
          options.log? "Mecano `chmod`: change mode form #{stat.mode} to #{options.mode}"
          do_chmod()
        do_chmod = ->
          fs.chmod options.ssh, options.destination, options.mode, (err) ->
            callback err, true
        do_stat()

## Dependencies

    fs = require 'ssh2-fs'
    misc = require './misc'
    wrap = require './misc/wrap'






