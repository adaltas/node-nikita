
crypto = require 'crypto'
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
each = require 'each'
util = require 'util'
Stream = require 'stream'
connect = require 'superexec/lib/connect'
buffer = require 'buffer'

ProxyStream = () ->
  # do nothing
util.inherits ProxyStream, Stream

module.exports = misc = 
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
            callback err, attr


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
          # For now, we dont accept options
          s = sftp.createReadStream path, options
          data = ''
          s.on 'data', (d) ->
            data += d.toString()
          s.on 'error', (err) ->
            callback err
          s.on 'end', ->
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
            callback()
    ###
    `mkdir(ssh, path, [chmod], callback)`
    -------------------------------------
    ###
    mkdir: (ssh, path, chmod, callback) ->
      if arguments.length is 3
        callback = chmod
        chmod = 0o0755
      unless ssh
        fs.mkdir path, chmod, (err) ->
          callback err
      else
        ssh.sftp (err, sftp) ->
          return callback err if err
          sftp.mkdir path, permissions: chmod, (err, attr) ->
            callback null, if err then false else true

    ###
    `exists(ssh, path, callback)`
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
  Normalize options and create an ssh connection if needed
  ###
  options: (options, callback) ->
    options = [options] unless Array.isArray options
    each(options)
    .on 'item', (option, next) ->
      option.if = [option.if] if option.if? and not Array.isArray option.if
      option.if_exists = [option.if_exists] if option.if_exists? and not Array.isArray option.if_exists
      option.not_if_exists = [option.not_if_exists] if option.not_if_exists? and not Array.isArray option.not_if_exists
      return next() unless option.ssh
      connect option.ssh, (err, ssh) ->
        return next err if err
        option.ssh = ssh
        next()
    .on 'both', (err) ->
      callback err, options





