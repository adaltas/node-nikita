

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
  each options
  .call (options, next) ->
    options.if_exists = [options.if_exists] if typeof options.if_exists is 'string'
    options.unless_exists = [options.unless_exists] if typeof options.unless_exists is 'string'
    if options.if_exists then for el, i in options.if_exists
      options.if_exists[i] = options.target if el is true and options.target
    if options.unless_exists then for v, i in options.unless_exists
      options.unless_exists[i] = options.target if v is true and options.target
    options.mode ?= options.chmod if options.chmod
    connection = ->
      return source() unless options.ssh
      return source() if options.ssh.config?.host
      connect options.ssh, (err, ssh) ->
        return next err if err
        options.ssh = ssh
        source()
    source = ->
      return target() unless options.source?
      return target() if /^\w+:/.test options.source # skip url
      tilde options.source, (source) ->
        options.source = source
        target()
    target = ->
      return mode() unless options.target?
      return mode() unless typeof options.target is 'string' # target is a function
      return mode() if /^\w+:/.test options.source # skip url
      tilde options.target, (target) ->
        options.target = target
        mode()
    mode = ->
      options.mode = parseInt(options.mode, 8) if typeof options.mode is 'string'
      next()
    connection()
  .then (err) ->
    callback err, options
