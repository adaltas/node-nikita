
# `uid_gid(options, callback)`

Read the "uid" and "gid" options. A username defined by the "uid" option will
be converted to a Unix user ID and a group defined by the "gid" option will
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
        return do_gid() unless options.uid?
        options.uid = parseInt options.uid, 10 if typeof options.uid is 'string' and /\d+/.test options.uid
        return do_gid() if typeof options.uid is 'number'
        module.exports.passwd options.ssh, options.store, options.uid, (err, user) ->
          return callback err if err
          if user
            options.uid = user.uid
            options.default_gid ?= user.gid
          do_gid()
      do_gid = ->
        return callback() unless options.gid?
        options.gid = parseInt options.gid, 10 if typeof options.gid is 'string' and /\d+/.test options.gid
        return callback() if typeof options.gid is 'number'
        module.exports.group options.ssh, options.store, options.gid, (err, group) ->
          return callback err if err
          options.gid = group.gid if group
          callback()
      do_uid()

    ###
    passwd(ssh, [user], callback)
    ----------------------
    Return information present in '/etc/passwd' and cache the 
    result in the provided ssh instance as "passwd".

    Result look like: 
        { root: {
            uid: '0',
            gid: '0',
            comment: 'root',
            home: '/root',
            shell: '/bin/bash' }, ... }
    ###
    module.exports.passwd = (ssh, store, username, callback) ->
      if arguments.length is 4
        # Username may be null, stop here
        return callback null, null unless username
        # Is user present in cache
        if store.cache_passwd and store.cache_passwd[username]
          return callback null, store.cache_passwd[username]
        # Reload the cache and check if user is here
        store.cache_passwd = null
        return module.exports.passwd ssh, store, (err, users) ->
          return callback err if err
          user = users[username]
          # Dont throw exception, just return undefined
          # return callback Error "User #{username} does not exists" unless user
          callback null, user
      callback = username
      username = null
      # Grab passwd from the cache
      return callback null, store.cache_passwd if store.cache_passwd
      # Alternative is to use the id command, eg `id -u ubuntu`
      ssh2fs.readFile ssh, '/etc/passwd', 'ascii', (err, lines) ->
        return callback err if err
        passwd = []
        for line in string.lines lines
          info = /(.*)\:\w\:(.*)\:(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless info
          passwd[info[1]] = uid: parseInt(info[2]), gid: parseInt(info[3]), comment: info[4], home: info[5], shell: info[6]
        store.cache_passwd = passwd
        callback null, passwd
    ###
    group(ssh, [group], callback)
    ----------------------
    Return information present in '/etc/group' and cache the 
    result in the provided ssh instance as "group".

    Result look like: 
        { root: {
            password: 'x'
            gid: 0,
            user_list: [] },
          bin: {
            password: 'x',
            gid: 1,
            user_list: ['bin','daemon'] } }
    ###
    module.exports.group = (ssh, store, group, callback) ->
      if arguments.length is 4
        # Group may be null, stop here
        return callback null, null unless group
        # Is group present in cache
        if store.cache_group and store.cache_group[group]
          return callback null, store.cache_group[group]
        # Reload the cache and check if user is here
        store.cache_group = null
        return module.exports.group ssh, store, (err, groups) ->
          return callback err if err
          gid = groups[group]
          # Dont throw exception, just return undefined
          # return callback Error "Group does not exists: #{group}" unless gid
          callback null, gid
      callback = group
      group = null
      # Grab group from the cache
      return callback null, store.cache_group if store.cache_group
      # Alternative is to use the id command, eg `id -g admin`
      ssh2fs.readFile ssh, '/etc/group', 'ascii', (err, lines) ->
        return callback err if err
        group = []
        for line in string.lines lines
          info = /(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless info
          group[info[1]] = password: info[2], gid: parseInt(info[3]), user_list: if info[4] then info[4].split ',' else []
        store.cache_group = group
        callback null, group

## Dependencies

    misc = require './index'
    ssh2fs = require 'ssh2-fs'
    string = require './string'
