
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

    module.exports = (goptions, options, callback) ->
      wrap arguments, (options, callback) ->
        # Validate parameters
        {ssh, mode} = options
        return callback new Error "Missing destination: #{options.destination}" unless options.destination
        options.log? "Mecano `chmod`: stat \"#{options.destination}\""
        fs.stat ssh, options.destination, (err, stat) ->
          return callback err if err
          return callback() if misc.mode.compare stat.mode, mode
          options.log? "Mecano `chmod`: change mode form #{stat.mode} to #{mode}"
          fs.chmod ssh, options.destination, mode, (err) ->
            callback err, true

## Dependencies

    fs = require 'ssh2-fs'
    misc = require './misc'
    wrap = require './misc/wrap'






