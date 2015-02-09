
# `chown(options, [goptions], callback)`

Change the ownership of a file or a directory.

## Options

*   `destination`   
    Where the file or directory is copied.   
*   `gid`   
    Group name or id who owns the file.   
*   `log`   
    Function called with a log related messages.   
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.   
*   `stat` (Stat instance, optional)   
    Pass the Stat object relative to the destination file or directory, to be
    used as an optimization.   
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

    module.exports = (options, callback) ->
      wrap arguments, (options, callback) ->
        # Validate parameters
        return callback Error "Missing destination option" unless options.destination?
        return callback Error "Missing one of uid or gid option" unless options.uid? and options.gid?
        # options.log? "Mecano `chown` [DEBUG]"
        do_stat = ->
          return do_compare options.stat if options.stat
          options.log? "Mecano `chown`: stat #{options.destination} [DEBUG]"
          fs.stat options.ssh, options.destination, (err, stat) ->
            return callback err if err
            do_compare stat
        do_compare = (stat) ->
            return callback() if stat.uid is options.uid and stat.gid is options.gid
            options.log? "Mecano `chown`: change uid from #{stat.uid} to #{options.uid} [INFO]" if stat.uid isnt options.uid
            options.log? "Mecano `chown`: change gid from #{stat.gid} to #{options.gid} [INFO]" if stat.gid isnt options.gid
            do_chown()
        do_chown = ->
          fs.chown options.ssh, options.destination, options.uid, options.gid, (err) ->
            callback err, true
        do_stat()

## Dependencies

    fs = require 'ssh2-fs'
    wrap = require './misc/wrap'








