
crypto = require 'crypto'
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
each = require 'each'
ssh2 = require 'ssh2'
util = require 'util'
Stream = require 'stream'
exec = require('child_process').exec
{EventEmitter} = require 'events'
fs = require 'fs'

ProxyStream = () ->
  # do nothing
util.inherits ProxyStream, Stream

module.exports = misc = 
  exec: (options, callback) ->
    if options.ssh
      child = new EventEmitter
      child.stdout = new ProxyStream
      child.stderr = new ProxyStream
      connection = null
      connect = ->
        if options.ssh instanceof ssh2
          connection = options.ssh
          return run()
        connection = new ssh2()
        connection.on 'error', (err) ->
          child.emit 'error', err
          callback err if callback
        connection.on 'ready', ->
          run()
        options.ssh.username ?= process.env['USER']
        options.ssh.port ?= 22
        if not options.ssh.password and not options.ssh.privateKey
          options.ssh.privateKey = fs.readFileSync("#{process.env['HOME']}/.ssh/id_rsa")
        connection.connect options.ssh
      run = ->
        stdout = stderr = ''
        connection.exec options.cmd, (err, stream) ->
          if err
            child.emit 'error', err
            callback err if callback
            return
          stream.on 'data', (data, extended) ->
            if extended is 'stderr'
              type = 'stderr'
              stderr += data if callback
            else
              type = 'stdout'
              stdout += data if callback
            child[type].emit 'data', data
          stream.on 'exit', (code, signal) ->
            if code isnt 0
              err = new Error 'Error'
              err.code = code
              err.signal = signal
            callback null, stdout, stderr if callback
      connect()
      child
    else
      cmdOptions = {}
      cmdOptions.env = options.env or process.env
      cmdOptions.cwd = options.cwd or null
      cmdOptions.uid = options.uid if options.uid
      cmdOptions.gid = options.gid if options.gid
      exec options.cmd, cmdOptions, callback
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
  `options(options)` Normalize options
  ###
  options: (options) ->
    options = [options] unless Array.isArray options
    for option in options
      option.if = [option.if] if option.if? and not Array.isArray option.if
      option.if_exists = [option.if_exists] if option.if_exists? and not Array.isArray option.if_exists
      option.not_if_exists = [option.not_if_exists] if option.not_if_exists? and not Array.isArray option.not_if_exists
    options





