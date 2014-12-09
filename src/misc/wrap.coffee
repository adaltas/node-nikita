

each = require 'each'
tilde = require 'tilde-expansion'
connect = require 'ssh2-connect'
misc = require './index'
conditions = require './conditions'
child = require './child'

###
Responsibilities:

*   Retrieve arguments
*   Normalize options
*   Handle conditions
*   Run multiple actions sequentially or concurrently
*   Handling modification count
*   Return a Mecano Child instance
*   Pass user arguments
###

module.exports = (args, handler) ->
  # Retrieve arguments
  [options, goptions, callback] = module.exports.args args
  isArray = Array.isArray options
  # Pass user arguments
  user_args = []
  result = child()
  # Handling modification count
  modified = 0
  finish = (err) ->
    unless isArray then user_args = for arg, i in user_args
      user_args[i] = arg[0]
    modified = !!modified #if goptions.boolmod
    callback err, modified, user_args... if callback
    result.end err, modified, user_args...
  # Normalize options
  module.exports.options options, (err, options) ->
    return finish err if err
    # Run multiple actions sequentially or concurrently
    each( options )
    .parallel(goptions.parallel)
    .on 'item', (options, next) ->
      # Handle conditions
      conditions.all options, next, ->
        handler options, (err, modif, args...) ->
          modified++ if not err and modif
          for arg, i in args
            user_args[i] ?= []
            user_args[i].push arg
          next err
    .on 'both', (err) ->
      finish err
  # Return a Mecano Child instance
  result

module.exports.args = (args, overwrite_goptions={}) ->
  if args.length is 2 and typeof args[1] is 'function'
    args[2] = args[1]
    args[1] = {}
  else if args.length is 1
    args[1] = {}
    args[2] = null
  args[1] = misc.merge parallel: 1, args[1], overwrite_goptions
  args


###

`options(options, callback)`
----------------------------
Normalize options. An ssh connection is needed if the key "ssh" 
hold a configuration object. The 'uid' and 'gid' fields will 
be converted to integer if they match a username or a group.   

`callback`          Received parameters are:   

*   `err`           Error object if any.   
*   `options`       Sanitized options.   

###
module.exports.options = (options, callback) ->
  options = [options] unless Array.isArray options
  each(options)
  .on 'item', (options, next) ->
    options.if = [options.if] if options.if? and not Array.isArray options.if
    # options.if_exists = options.destination if options.if_exists is true and options.destination
    options.if_exists = [options.if_exists] if typeof options.if_exists is 'string'
    # options.not_if_exists = options.destination if options.not_if_exists is true and options.destination
    options.not_if_exists = [options.not_if_exists] if typeof options.not_if_exists is 'string'
    if options.if_exists then for el, i in options.if_exists
      options.if_exists[i] = options.destination if el is true and options.destination
    if options.not_if_exists then for v, i in options.not_if_exists
      options.not_if_exists[i] = options.destination if v is true and options.destination
    options.mode ?= options.chmod if options.chmod
    connection = ->
      return source() unless options.ssh
      return source() if options.ssh._host
      connect options.ssh, (err, ssh) ->
        return next err if err
        options.ssh = ssh
        source()
    source = ->
      return destination() unless options.source?
      return destination() if /^\w+:/.test options.source # skip url
      tilde options.source, (source) ->
        options.source = source
        destination()
    destination = ->
      return mode() unless options.destination?
      return mode() unless typeof options.destination is 'string' # destination is a function
      return mode() if /^\w+:/.test options.source # skip url
      tilde options.destination, (destination) ->
        options.destination = destination
        mode()
    mode = ->
      options.mode = parseInt(options.mode, 8) if typeof options.mode is 'string'
      uid()
    uid = ->
      # uid=`id -u $USER`,
      return gid() unless options.uid
      options.uid = parseInt options.uid, 10 if typeof options.uid is 'string' and /\d+/.test options.uid
      return gid() if typeof options.uid is 'number'
      misc.ssh.passwd options.ssh, options.uid, (err, user) ->
        return next err if err
        if user
          options.uid = user.uid
          options.gid ?= user.gid
        gid()
    gid = ->
      # gid=`getent group $GROUP | cut -d: -f3`
      return next() unless options.gid
      options.gid = parseInt options.gid, 10 if typeof options.gid is 'string' and /\d+/.test options.gid
      return next() if typeof options.gid is 'number'
      misc.ssh.group options.ssh, options.gid, (err, group) ->
        return next err if err
        options.gid = group.gid if group
        next()
    connection()
  .on 'both', (err) ->
    callback err, options
