
# `uid_gid(options, callback)`

Read the "uid" and "gid" options. A username defined by the "uid" option will
be converted to a Unix user ID and a group dedfined by the "gid" option will
be converted to a Unix group ID.    

At the moment, this only work with Unix username because it only read the
"/etc/passwd" file. A future implementation might execute a system command to
retrieve information from external identity provideds.   

## Exemple

```coffee
options =
  uid: 'me'
  gid: 'metoo'
uid_gid options, (err) ->
  console.log options.uid
  console.log options.gid
```

    module.exports = (options, callback) ->
      do_uid = ->
        # uid=`id -u $USER`,
        return do_gid() unless options.uid?
        options.uid = parseInt options.uid, 10 if typeof options.uid is 'string' and /\d+/.test options.uid
        return do_gid() if typeof options.uid is 'number'
        misc.ssh.passwd options.ssh, options.uid, (err, user) ->
          return do_gid err if err
          if user
            options.uid = user.uid
            options.gid ?= user.gid
          do_gid()
      do_gid = ->
        return callback() unless options.gid?
        options.gid = parseInt options.gid, 10 if typeof options.gid is 'string' and /\d+/.test options.gid
        return callback() if typeof options.gid is 'number'
        misc.ssh.group options.ssh, options.gid, (err, group) ->
          return callback err if err
          options.gid = group.gid if group
          callback()
      do_uid()

## Dependencies

    misc = require './index'