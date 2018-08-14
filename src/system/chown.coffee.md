
# `nikita.system.chown`

Change the ownership of a file or a directory.

## Options

* `gid`   
  Group name or id who owns the target file.   
* `stats` (Stat instance, optional)   
  Pass the Stats object relative to the target file or directory, to be
  used as an optimization, discovered otherwise.   
* `target`   
  Where the file or directory is copied.   
* `uid`   
  User name or id who owns the target file.   

## Callback Parameters

* `err`   
  Error object if any.   
* `status`   
  Value is "true" if file ownership was created or modified.   

## Example

```js
require('nikita').system.chown({
  target: '~/my/project',
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

    module.exports = ({options}) ->
      @log message: "Entering chown", level: 'DEBUG', module: 'nikita/lib/system/chown'
      if options.stat
        console.log 'Deprecated Option: receive options.stat instead of options.stats in system.chown'
        options.stats = options.stat
      # SSH connection
      ssh = @ssh options.ssh
      # Normalize options
      options.target = options.argument if options.argument?
      options.uid = null if options.uid is false
      options.gid = null if options.gid is false
      # Validate parameters
      throw Error "Missing target option" unless options.target?
      throw Error "Missing one of uid or gid option" unless options.uid? or options.gid?
      # Convert user and group names to uid and gid if necessary
      @system.uid_gid
        uid: options.uid
        gid: options.gid
        shy: true
      , (err, {status, uid, gid}) ->
        options.uid = uid
        options.gid = gid
      # Use option 'stat' short-circuit or discover
      @call unless: !!options.stats, ({}, callback) ->
        @log message: "Stat #{options.target}", level: 'DEBUG', module: 'nikita/lib/chown'
        @fs.stat ssh: options.ssh, target: options.target, (err, {stats}) ->
          return callback Error "Target Does Not Exist: #{JSON.stringify options.target}" if err?.code is 'ENOENT'
          return callback err if err
          options.stats = stats
          callback()
      # Detect changes
      @call ({}, callback) ->
        if (not options.uid? or options.stats.uid is options.uid) and (not options.gid? or options.stats.gid is options.gid)
          @log message: "Matching ownerships on '#{options.target}'", level: 'INFO', module: 'nikita/lib/chown'
          return callback()
        callback null, true
      # Apply changes
      @call if: (-> @status -1), ({}, callback) ->
        options.uid ?= options.stats.uid
        options.gid ?= options.stats.gid
        @fs.chown ssh: options.ssh, target: options.target, uid: options.uid, gid: options.gid, sudo: options.sudo, (err) ->
          @log message: "change uid from #{options.stats.uid} to #{options.uid}", level: 'WARN', module: 'nikita/lib/chown' if options.stats.uid is not options.uid
          @log message: "change gid from #{options.stats.gid} to #{options.gid}", level: 'WARN', module: 'nikita/lib/chown' if options.stats.gid is not options.gid
          callback err
