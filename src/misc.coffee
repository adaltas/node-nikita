
crypto = require 'crypto'
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
each = require 'each'

module.exports = misc = 
  file: 
    ###
    `hash(file, [digest], callback)`
    --------------------------------
    Output the message digest of a supplied file in hexadecimal
    form. If the provided file is a directory, the returned hash
    is the sum of all the files it contains. 

    For now, the message digests is limited to md5. 
    Throw an error if file does not exist or is a directory.
    ###
    hash: (file, digest, callback) ->
      if arguments.length is 2
        callback = digest
        digest = 'md5'
      md5 = []
      fs.stat file, (err, stat) ->
        return callback new Error "Does not exist: #{file}" if err?.code is 'ENOENT'
        return callback err if err
        file += '/**' if stat.isDirectory()
        each()
        .files(file)
        .on 'item', (item, next) ->
          shasum = crypto.createHash 'md5'
          fs.ReadStream(item)
          .on 'data', (data) ->
            shasum.update data
          .on 'error', (err) ->
            return next() if err.code is 'EISDIR'
            next err
          .on 'end', ->
            md5.push shasum.digest 'hex'
            next()
        .on 'error', (err) ->
          callback err
        .on 'end', ->
          switch md5.length
            when 0
              if stat.isFile() 
              then callback new Error "Does not exist: #{file}"
              else callback null, crypto.createHash('md5').update('').digest('hex')
            when 1
              return callback null, md5[0]
            else
              md5 = crypto.createHash('md5').update(md5.join('')).digest('hex')
              return callback null, md5

        # return md5[0] if md5.length is 1

    ###
    `compare(files, callback)`
    --------------------------
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





