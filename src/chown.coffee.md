
# `chown(options, callback)`

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

## Note

To list all files owner by a user or a uid, run:

```bash
find /var/tmp -user `whoami`
find /var/tmp -uid 1000
find / -uid $old_uid -print | xargs chown $new_uid:$new_gid
```

## Source Code

    module.exports = (options, callback) ->
      # Validate parameters
      return callback Error "Missing destination option" unless options.destination?
      return callback Error "Missing one of uid or gid option" unless options.uid? or options.gid?
      do_uid_gid = ->
        uid_gid options, (err) ->
          return callback err if err
          do_stat()
      do_stat = ->
        # Option 'stat' short-circuit
        return do_chown options.stat if options.stat
        options.log? "Mecano `chown`: stat #{options.destination} [DEBUG]"
        fs.stat options.ssh, options.destination, (err, stat) ->
          return callback err if err
          do_chown stat
      do_chown = (stat) ->
        # Detect changes
        if stat.uid is options.uid and stat.gid is options.gid
          options.log? "Mecano `chmod`: identical ownerships on '#{options.destination}' [INFO]"
          return callback()
        # Apply changes
        fs.chown options.ssh, options.destination, options.uid, options.gid, (err) ->
          options.log? "Mecano `chown`: change uid from #{stat.uid} to #{options.uid} [WARN]" if options.uid and stat.uid isnt options.uid
          options.log? "Mecano `chown`: change gid from #{stat.gid} to #{options.gid} [WARN]" if options.gid and stat.gid isnt options.gid
          callback err, true
      do_uid_gid()

## Dependencies

    fs = require 'ssh2-fs'
    uid_gid = require './misc/uid_gid'








