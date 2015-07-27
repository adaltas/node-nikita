

each = require 'each'
tilde = require 'tilde-expansion'
connect = require 'ssh2-connect'
misc = require './index'
conditions = require './conditions'


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
  # options = [options] unless Array.isArray options
  each options
  .run (options, next) ->
    # options.if = [options.if] if options.if? and not Array.isArray options.if
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
      return source() if options.ssh.config?.host
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
      next()
    connection()
  .then (err) ->
    callback err, options



