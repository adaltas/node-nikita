
fs = require 'fs'
path = require 'path'
each = require 'each'
{merge} = require 'mixme'
util = require 'util'
Stream = require 'stream'
exec = require 'ssh2-exec'
ini = require './ini'
string = require './string'
array = require './array'
docker = require './docker'
ssh = require './ssh'

misc = module.exports =
  docker: require './docker'
  stats: require './stats'
  ssh: require './ssh'
  object:
    equals: (obj1, obj2, keys) ->
      keys1 = Object.keys obj1
      keys2 = Object.keys obj2
      if keys
        keys1 = keys1.filter (k) -> keys.indexOf(k) isnt -1
        keys2 = keys2.filter (k) -> keys.indexOf(k) isnt -1
      else keys = keys1
      return false if keys1.length isnt keys2.length
      for k in keys
        return false if obj1[k] isnt obj2[k]
      return true
    diff: (obj1, obj2, keys) ->
      unless keys
        keys1 = Object.keys obj1
        keys2 = Object.keys obj2
        keys = array.merge keys1, keys2, array.unique keys1
      diff = {}
      for k, v of obj1
        continue unless keys.indexOf(k) >= 0
        continue if obj2[k] is v
        diff[k] = []
        diff[k][0] = v
      for k, v of obj2
        continue unless keys.indexOf(k) >= 0
        continue if obj1[k] is v
        diff[k] ?= []
        diff[k][1] = v
      diff
    clone: (obj) ->
      merge {}, obj
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
    console.warn 'Function merge is deprecated, use mixme instead'
    target = arguments[0]
    from = 1
    to = arguments.length
    if typeof target is 'boolean'
      inverse = !! target
      target = arguments[1]
      from = 2
    target ?= {}
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
          if copy? and typeof copy is 'object' and not Array.isArray(copy) and copy not instanceof RegExp and not Buffer.isBuffer copy
            clone = src and ( if src and typeof src is 'object' then src else {} )
            # Never move original objects, clone them
            target[ name ] = misc.merge false, clone, copy
          # Don't bring in undefined values
          else if copy isnt undefined
            copy = copy.slice(0) if Array.isArray copy
            target[ name ] = copy unless inverse and typeof target[ name ] isnt 'undefined'
    # Return the modified object
    target
  kadmin: (options, cmd) ->
    realm = if options.realm then "-r #{options.realm}" else ''
    if options.kadmin_principal
    then "kadmin #{realm} -p #{options.kadmin_principal} -s #{options.kadmin_server} -w #{options.kadmin_password} -q '#{cmd}'"
    else "kadmin.local #{realm} -q '#{cmd}'"
  ini: ini
