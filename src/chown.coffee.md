
# `chown(options, [goptions], callback)`

Change the ownership of a file or a directory.

## Options

*   `destination`   
    Where the file or directory is copied.   
*   `gid`   
    Group name or id who owns the file.   
*   `log`   
    Function called with a log related messages.   
*   `mode`   
    Permissions of the file or the parent directory.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `uid`   
    User name or id who owns the file.   

## Callback parameters

*   `err`   
    Error object if any.   
*   `modified`   
    Number of ownerships with modifications.   

## Example

```js
require('mecano').chown({
  destination: '~/my/project',
  uid: 'my_user'
  gid: 'my_group'
}, function(err, modified){
  console.log(err ? err.message : 'File was modified: ' + modified);
});
```

## Source Code

    module.exports = (goptions, options, callback) ->
      wrap arguments, (options, callback) ->
        # Validate parameters
        {ssh, uid, gid} = options
        return callback new Error "Missing destination: #{options.destination}" unless options.destination
        return callback() unless uid? and gid?
        options.log? "Mecano `chown`: stat #{options.destination}"
        fs.stat ssh, options.destination, (err, stat) ->
          return callback err if err
          return callback() if stat.uid is uid and stat.gid is gid
          options.log? "Mecano `chown`: change uid from #{stat.uid} to #{uid}" if stat.uid isnt uid
          options.log? "Mecano `chown`: change gid from #{stat.gid} to #{gid}" if stat.gid isnt gid
          fs.chown ssh, options.destination, uid, gid, (err) ->
            callback err, true

## Dependencies

    fs = require 'ssh2-fs'
    wrap = require './misc/wrap'








