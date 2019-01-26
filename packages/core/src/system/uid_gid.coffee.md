
# `nikita.uid_gid`

Normalize the "uid" and "gid" options. A username defined by the "uid" option will
be converted to a Unix user ID and a group defined by the "gid" option will
be converted to a Unix group ID.    

At the moment, this only work with Unix username because it only read the
"/etc/passwd" file. A future implementation might execute a system command to
retrieve information from external identity provideds.   

## Options

* `cache` (boolean)   
  Cache the result inside the store.
* `group_target` (string)   
  Path to the group definition file, default to "/etc/group".
* `passwd_target` (string)   
  Path to the passwd definition file, default to "/etc/passwd".
* `uid` (string|integer)   
  Convert the user name to a Unix ID.
* `gid` (string|integer)   
  Convert the group name to a Unix ID.

## Exemple

```js
require('nikita').system.uid_gid({
  uid: 'myuser',
  gid: 'mygroup'
}, function(err, {uid, gid}){
  console.log(options.uid)
  console.log(options.gid)
})
```

## Source Code

    module.exports = ({options}, callback) ->
      options.uid = parseInt options.uid, 10 if typeof options.uid is 'string' and /^\d+$/.test options.uid
      options.gid = parseInt options.gid, 10 if typeof options.gid is 'string' and /^\d+$/.test options.gid
      @system.user.read
        if: options.uid and typeof options.uid is 'string'
        target: options.passwd_target
        uid: options.uid
        shy: false
      , (err, {status, user}) ->
        throw err if err
        return unless status
        options.uid = user.uid
        options.default_gid = user.gid
      @system.group.read
        if: options.gid and typeof options.gid is 'string'
        target: options.group_target
        gid: options.gid
        shy: false
      , (err, {status, group}) ->
        throw err if err
        return unless status
        options.gid = group.gid
      @next (err, {status}) ->
        callback err, status: status, uid: options.uid, gid: options.gid, default_gid: options.default_gid 
