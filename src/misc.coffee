
crypto = require 'crypto'
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
each = require 'each'
util = require 'util'
Stream = require 'stream'
exec = require 'superexec'
connect = require 'superexec/lib/connect'
buffer = require 'buffer'
rimraf = require 'rimraf'

ProxyStream = () ->
  # do nothing
util.inherits ProxyStream, Stream

# (only valid with fs.lstat())

ST_MODE = 
  S_IFIFO:  parseInt '0010000', 8  # named pipe (fifo)
  S_IFCHR:  parseInt '0020000', 8  # character special
  S_IFDIR:  parseInt '0040000', 8  # directory
  S_IFBLK:  parseInt '0060000', 8  # block special
  S_IFREG:  parseInt '0100000', 8  # regular
  S_IFLNK:  parseInt '0120000', 8  # symbolic link
  S_IFSOCK: parseInt '0140000', 8  # socket */
  S_IFWHT:  parseInt '0160000', 8  # whiteout */

class Stat
  constructor: (stat) ->
    for k, v of stat
      @[k] = v
    @
  isFile: -> if @permissions & ST_MODE.S_IFREG then true else false
  isDirectory: -> if @permissions & ST_MODE.S_IFDIR then true else false
  isBlockDevice: -> if @permissions & ST_MODE.S_IFBLK then true else false
  isCharacterDevice: -> if @permissions & ST_MODE.S_IFCHR then true else false
  isSymbolicLink: -> if @permissions & ST_MODE.S_IFLNK then true else false
  isFIFO: -> if @permissions & ST_MODE.S_IFIFO then true else false
  isSocket: -> if @permissions & ST_MODE.S_IFSOCK then true else false

misc = module.exports = 
  string:
    ###
    `string.hash(file, [algorithm], callback)`
    ------------------------------------------
    Output the hash of a supplied string in hexadecimal 
    form. The default algorithm to compute the hash is md5.
    ###
    hash: (data, algorithm) ->
      if arguments.length is 1
        algorithm = 'md5'
      crypto.createHash(algorithm).update(data).digest('hex')
  file:
    stat: (ssh, path, callback) ->
      # Not yet test, no way to know if file is a direct or a link
      unless ssh
        # { dev: 16777218, mode: 16877, nlink: 19, uid: 501, gid: 20,
        # rdev: 0, blksize: 4096, ino: 1736226, size: 646, blocks: 0,
        # atime: Wed Feb 27 2013 23:25:07 GMT+0100 (CET), mtime: Tue Jan 29 2013 23:29:28 GMT+0100 (CET), ctime: Tue Jan 29 2013 23:29:28 GMT+0100 (CET) }
        fs.stat path, (err, stat) ->
          callback err, stat
      else
        # { size: 646, uid: 501, gid: 20, permissions: 16877, 
        # atime: 1362003965, mtime: 1359498568 }
        ssh.sftp (err, sftp) ->
          return callback err if err
          sftp.stat path, (err, attr) ->
            if err and err.type is 'NO_SUCH_FILE'
              err.code = 'ENOENT'
              return callback err
            callback err, new Stat attr
    ###
    `readFile(ssh, path, [options], callback)`
    -----------------------------------------
    ###
    readFile: (ssh, path, options, callback) ->
      if arguments.length is 3
        callback = options
        options = {}
      options.encoding ?= 'utf8'
      unless ssh
        fs.readFile path, options.encoding, (err, content) ->
          callback err, content
      else
        ssh.sftp (err, sftp) ->
          return callback err if err
          s = sftp.createReadStream path, options
          data = ''
          s.on 'data', (d) ->
            data += d.toString()
          s.on 'error', (err) ->
            callback err
          s.on 'close', ->
            sftp.end()
            callback null, data
    ###
    `writeFile(ssh, path, content, [options], callback)`
    -----------------------------------------
    ###
    writeFile: (ssh, path, content, options, callback) ->
      if arguments.length is 4
        callback = options
        options = {}
      unless ssh
        fs.writeFile path, content, (err, content) ->
          callback err, content
      else
        ssh.sftp (err, sftp) ->
          return callback err if err
          write = ->
            s = sftp.createWriteStream path, options
            if typeof content is 'string' or buffer.Buffer.isBuffer content
              s.write content if content
              s.end()
            else
              content.pipe s
            s.on 'error', (err) ->
              callback err
            s.on 'end', ->
              s.destroy()
            s.on 'close', ->
              chown()
          chown = ->
            return end() unless options.uid or options.gid
            sftp.chown path, options.uid, options.gid, (err) ->
              return callback err if err
              end()
          end = ->
            sftp.end()
            callback()
          write()
    ###
    `mkdir(ssh, path, [options], callback)`
    -------------------------------------
    Note, if option is not a string, it is considered to be the permission mode.
    ###
    mkdir: (ssh, path, options, callback) ->
      if arguments.length is 3
        callback = options
        options = 0o0755
      if typeof options isnt 'object'
        options = mode: options
      if options.permissions
        process.stderr.write 'Deprecated, use mode instead of permissions'
        options.mode = options.permissions
      unless ssh
        fs.mkdir path, options.mode, (err) ->
          callback err
      else
        ssh.sftp (err, sftp) ->
          return callback err if err
          # size - < integer > - Resource size in bytes.
          # uid - < integer > - User ID of the resource.
          # gid - < integer > - Group ID of the resource.
          # permissions - < integer > - Permissions for the resource.
          # atime - < integer > - UNIX timestamp of the access time of the resource.
          # mtime - < integer > - UNIX timestamp of the modified time of the resource.
          # console.log '??', options
          # options = misc.merge {}, options
          # options.permissions = options.mode if options.mode
          # for k, v of options
          #   console.log k, v if k isnt 'ssh'
          mkdir = ->
            sftp.mkdir path, options, (err, attr) ->
              # callback null, if err then false else true
              chown()
          chown = ->
            return chmod() unless options.uid or options.gid
            sftp.chown path, options.uid, options.gid, (err) ->
              return callback err if err
              chmod()
          chmod = ->
            return callback() unless options.mode
            sftp.chmod path, options.mode, (err) ->
              callback err
          mkdir()
    ###
    `exists(ssh, path, callback)`
    -----------------------------

    `options`         Command options include:   

    *   `ssh`         SSH connection in case of a remote file path.  
    *   `path`        Path to test.   
    *   `callback`    Callback to return the result.   

    `callback`        Received parameters are:   

    *   `err`         Error object if any.   
    *   `exists`      True if the file exists.   
    ###
    exists: (ssh, path, callback) ->
      unless ssh
        fs.exists path, (exists) ->
          callback null, exists
      else
        ssh.sftp (err, sftp) ->
          return callback err if err
          sftp.stat path, (err, attr) ->
            callback null, if err then false else true
    ###
    `files.hash(file, [algorithm], callback)`
    -----------------------------------------
    Output the hash of a supplied file in hexadecimal 
    form. If the provided file is a directory, the returned hash 
    is the sum of all the hashs of the files it recursively 
    contains. The default algorithm to compute the hash is md5.

    Throw an error if file does not exist unless it is a directory.
    ###
    hash: (file, algorithm, callback) ->
      if arguments.length is 2
        callback = algorithm
        algorithm = 'md5'
      hashs = []
      fs.stat file, (err, stat) ->
        return callback new Error "Does not exist: #{file}" if err?.code is 'ENOENT'
        return callback err if err
        file += '/**' if stat.isDirectory()
        each()
        .files(file)
        .on 'item', (item, next) ->
          shasum = crypto.createHash algorithm
          fs.ReadStream(item)
          .on 'data', (data) ->
            shasum.update data
          .on 'error', (err) ->
            return next() if err.code is 'EISDIR'
            next err
          .on 'end', ->
            hashs.push shasum.digest 'hex'
            next()
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          switch hashs.length
            when 0
              if stat.isFile() 
              then callback new Error "Does not exist: #{file}"
              else callback null, crypto.createHash(algorithm).update('').digest('hex')
            when 1
              return callback null, hashs[0]
            else
              hashs = crypto.createHash(algorithm).update(hashs.join('')).digest('hex')
              return callback null, hashs
    ###
    `files.compare(files, callback)`
    --------------------------------
    Compare the hash of multiple file. Return the file md5 
    if the file are the same or false otherwise.
    ###
    compare: (files, callback) ->
      return callback new Error 'Minimum of 2 files' if files.length < 2
      result = null
      each(files)
      .parallel(true)
      .on 'item', (file, next) ->
        misc.file.hash file, (err, md5) ->
          return next err if err
          if result is null
            result = md5 
          else if result isnt md5
            result = false 
          next()
      .on 'error', (err) ->
        callback err
      .on 'end', ->
        callback null, result
    ###
    remove(ssh, path, callback)
    ---------------------------
    Remove a file or directory
    ###
    remove: (ssh, path, callback) ->
      unless ssh
        rimraf path, callback
      else
        # Not very pretty but fast and no time to try make a version of rimraf over ssh
        child = exec "rm -rf #{path}", ssh: ssh
        child.on 'exit', (code) ->
          callback null, code
  ssh:
    ###
    passwd(sftp, [user], callback)
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
    passwd: (ssh, username, callback) ->
      if arguments.length is 3
        # Group may be null, stop here
        return callback null, null unless username
        return misc.ssh.passwd ssh, (err, users) ->
          return err if err
          user = users[username]
          return new Error "User #{username} does not exists" unless user
          callback null, user
      callback = username
      username = null
      # Grab passwd from the cache
      return callback null, ssh.passwd if ssh.passwd
      # Alternative is to use the id command, eg `id -u ubuntu`
      misc.file.readFile ssh, '/etc/passwd', (err, lines) ->
        return callback err if err
        passwd = []
        for line in lines.split '\n'
          info = /(.*)\:\w\:(.*)\:(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless info
          passwd[info[1]] = uid: parseInt(info[2]), gid: parseInt(info[3]), comment: info[4], home: info[5], shell: info[6]
        ssh.passwd = passwd
        callback null, passwd
    ###
    group(sftp, [group], callback)
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
    group: (ssh, group, callback) ->
      if arguments.length is 3
        # Group may be null, stop here
        return callback null, null unless group
        return misc.ssh.group ssh, (err, groups) ->
          return err if err
          group = groups[group]
          return new Error "Group #{group} does not exists" unless group
          callback null, group
      callback = group
      group = null
      # Grab group from the cache
      return callback null, ssh.group if ssh.group
      # Alternative is to use the id command, eg `id -g admin`
      misc.file.readFile ssh, '/etc/group', (err, lines) ->
        return callback err if err
        group = []
        for line in lines.split '\n'
          info = /(.*)\:(.*)\:(.*)\:(.*)/.exec line
          continue unless info
          group[info[1]] = password: info[2], gid: parseInt(info[3]), user_list: if info[4] then info[4].split ',' else []
        ssh.group = group
        callback null, group
  ###
  `isPortOpen(port, host, callback)`: Check if a port is already open

  ###
  isPortOpen: (port, host, callback) ->
    if arguments.length is 2
      callback = host
      host = '127.0.0.1'
    exec "nc #{host} #{port} < /dev/null", (err, stdout, stderr) ->
      return callback null, true unless err
      return callback null, false if err.code is 1
      callback err
  ###
  `merge([inverse], obj1, obj2, ...]`: Recursively merge objects
  --------------------------------------------------------------
  On matching keys, the last object take precedence over previous ones 
  unless the inverse arguments is provided as true. Only objects are 
  merge, arrays are overwritten.

  Enrich an existing object with a second one:
    obj1 = { a_key: 'a value', b_key: 'b value'}
    obj2 = { b_key: 'new b value'}
    result = misc.merge obj1, obj2
    assert.eql result, obj1
    assert.eql obj1.b_key, 'new b value'

  Create a new object from two objects:
    obj1 = { a_key: 'a value', b_key: 'b value'}
    obj2 = { b_key: 'new b value'}
    result = misc.merge {}, obj1, obj2
    assert.eql result.b_key, 'new b value'

  Using inverse:
    obj1 = { b_key: 'b value'}
    obj2 = { a_key: 'a value', b_key: 'new b value'}
    misc.merge true, obj1, obj2
    assert.eql obj1.a_key, 'a value'
    assert.eql obj1.b_key, 'b value'

  ###
  merge: () ->
    target = arguments[0]
    from = 1
    to = arguments.length
    if typeof target is 'boolean'
      inverse = !! target
      target = arguments[1]
      from = 2
    # Handle case when target is a string or something (possible in deep copy)
    if typeof target isnt "object" and typeof target isnt 'function'
      target = {}
    for i in [from ... to]
      # Only deal with non-null/undefined values
      if (options = arguments[ i ]) isnt null
        # Extend the base object
        for name of options 
          src = target[ name ]
          copy = options[ name ]
          # Prevent never-ending loop
          continue if target is copy
          # Recurse if we're merging plain objects
          if copy? and typeof copy is 'object' and not Array.isArray(copy)
            clone = src and ( if src and typeof src is 'object' then src else {} )
            # Never move original objects, clone them
            target[ name ] = misc.merge false, clone, copy
          # Don't bring in undefined values
          else if copy isnt undefined
            target[ name ] = copy unless inverse and typeof target[ name ] isnt 'undefined'
    # Return the modified object
    target
  ###
  `options(options, callback)`
  ----------------------------
  Normalize options. An ssh connection if needed if the key "ssh" 
  hold a configuration object. The 'uid' and 'gid' fields will 
  be converted to integer if they match a username or a group.
  ###
  options: (options, callback) ->
    options = [options] unless Array.isArray options
    each(options)
    .on 'item', (options, next) ->
      options.if = [options.if] if options.if? and not Array.isArray options.if
      options.if_exists = [options.if_exists] if options.if_exists? and not Array.isArray options.if_exists
      options.not_if_exists = [options.not_if_exists] if options.not_if_exists? and not Array.isArray options.not_if_exists
      connection = ->
        return next() unless options.ssh
        connect options.ssh, (err, ssh) ->
          return next err if err
          options.ssh = ssh
          uid()
      uid = ->
        return gid() unless options.uid
        return gid() if typeof options.uid is 'number' or /\d+/.test options.uid
        misc.ssh.passwd options.ssh, options.uid, (err, user) ->
          options.uid = user.uid
          options.gid ?= user.gid
          gid()
      gid = ->
        return next() unless options.gid
        return next() if typeof options.gid is 'number' or /\d+/.test options.gid
        misc.ssh.group options.ssh, options.gid, (err, group) ->
          options.gid = group.gid if group
          next()
      connection()
    .on 'both', (err) ->
      callback err, options





