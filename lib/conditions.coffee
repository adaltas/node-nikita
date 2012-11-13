
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
each = require 'each'

###
Conditionnal properties
###
module.exports = 
  ###

  `all(options, failed, succeed)` Run all conditions
  ---------------------------------------------------

  `opts`
  Command options

  `failed`
  Failed callback, called when a condition failed

  `succeed`
  Succeed callback, only called if all the condition succeed

  ###
  all: (options, failed, succeed) -> 
    each([@if, @if_exists, @not_if_exists])
    .on 'item', (next, condition) ->
      condition(options, failed, next)
    .on('error', failed)
    .on('end', succeed)
  ###
  `if` Run action for a user defined condition
  --------------------------------------------

  Work on the property `if` in `options`. When `if` 
  is a boolean, its value determine to the output. If it's 
  a callback, the function is called with the `options`, 
  `failed` and `succeed` arguments. If it'a an array, all its element
  must positively resolve for the condition to pass.

  Updating the content of a file if we are the owner

      mecano.render
        source:'./file'
        if: (options, failed, succeed) ->
          fs.stat options.source, (err, stat) ->
            # File does not exists
            return failed err if err
            # Failed if we dont own the file
            return  failed() unless stat.uid is process.getuid()
            # Succeed if we own the file
            succeed()

  ###
  if: (options, failed, succeed) ->
    return succeed() unless options.if?
    ok = true
    each(options.if)
    .on 'item', (next, si) ->
      return next() unless ok
      if typeof si is 'boolean'
        ok = false unless si
        next()
      else if typeof si is 'function'
        si options, ( -> ok = false; next arguments...), next
    .on 'both', (err) ->
      return failed err if err or not ok
      succeed()
  ###
  
  `if_exists` Run action if a file exists
  ----------------------------------------

  Work on the property `if_exists` in `options`. The value may 
  be a file path or an array of file paths.

  The callback `succeed` is called if all the provided paths 
  exists otherwise the callback `failed` is called.

  ###
  if_exists: (options, failed, succeed) ->
    return succeed() unless options.if_exists?
    each(options.if_exists)
    .on 'item', (next, if_exists) ->
      # await fs.exists if_exists, defer exists
      # if exists then next() else failed()
      fs.exists if_exists, (exists) ->
        if exists then next() else failed()
    .on 'end', succeed
  ###

  `not_if_exists` Skip action if a file exists
  ---------------------------------------------

  Work on the property `not_if_exists` in `options`. The value may 
  be a file path or an array of file paths.

  The callback `succeed` is called if none of the provided paths 
  exists otherwise the callback `failed` is called.

  ###
  not_if_exists: (options, failed, succeed) ->
    return succeed() unless options.not_if_exists?
    each(options.not_if_exists)
    .on 'item', (next, not_if_exists) ->
      fs.exists not_if_exists, (exists) ->
        if exists
        then failed()
        else next()
      # await fs.exists not_if_exists, defer exists
      # if exists then failed() else next()
    .on 'end', succeed
