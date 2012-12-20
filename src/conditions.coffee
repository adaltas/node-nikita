
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
each = require 'each'

###
Conditionnal properties
###
module.exports = 
  ###

  `all(options, skip, succeed)` Run all conditions
  ---------------------------------------------------

  `opts`
  Command options

  `skip`
  Skip callback, called when a condition is not fulfill. May also be called with on error on failure

  `succeed`
  Succeed callback, only called if all the condition succeed

  ###
  all: (options, skip, succeed) -> 
    each([@if, @if_exists, @not_if_exists, @should_exist])
    .on 'item', (condition, next) ->
      condition(options, skip, next)
    .on('error', skip)
    .on('end', succeed)
  ###
  `if` Run action for a user defined condition
  --------------------------------------------

  Work on the property `if` in `options`. When `if` 
  is a boolean, its value determine to the output. If it's 
  a callback, the function is called with the `options`, 
  `skip` and `succeed` arguments. If it'a an array, all its element
  must positively resolve for the condition to pass.

  Updating the content of a file if we are the owner

      mecano.render
        source:'./file'
        if: (options, skip, succeed) ->
          fs.stat options.source, (err, stat) ->
            # File does not exists
            return skip err if err
            # Skip if we dont own the file
            return  skip() unless stat.uid is process.getuid()
            # Succeed if we own the file
            succeed()

  ###
  if: (options, skip, succeed) ->
    return succeed() unless options.if?
    ok = true
    each(options.if)
    .on 'item', (si, next) ->
      return next() unless ok
      if typeof si is 'boolean'
        ok = false unless si
        next()
      else if typeof si is 'function'
        si options, ( -> ok = false; next arguments...), next
    .on 'both', (err) ->
      return skip err if err or not ok
      succeed()
  ###
  
  `if_exists` Run action if a file exists
  ----------------------------------------

  Work on the property `if_exists` in `options`. The value may 
  be a file path or an array of file paths.

  The callback `succeed` is called if all the provided paths 
  exists otherwise the callback `skip` is called.

  ###
  if_exists: (options, skip, succeed) ->
    return succeed() unless options.if_exists?
    each(options.if_exists)
    .on 'item', (if_exists, next) ->
      # await fs.exists if_exists, defer exists
      # if exists then next() else skip()
      fs.exists if_exists, (exists) ->
        if exists then next() else skip()
    .on 'end', succeed
  ###

  `not_if_exists` Skip action if a file exists
  ---------------------------------------------

  Work on the property `not_if_exists` in `options`. The value may 
  be a file path or an array of file paths.

  The callback `succeed` is called if none of the provided paths 
  exists otherwise the callback `skip` is called.

  ###
  not_if_exists: (options, skip, succeed) ->
    return succeed() unless options.not_if_exists?
    each(options.not_if_exists)
    .on 'item', (not_if_exists, next) ->
      fs.exists not_if_exists, (exists) ->
        if exists
        then next new Error
        else next()
    .on 'error', ->
      skip()
    .on 'end', succeed
  ###

  `should_exist` Ensure a file exist
  ----------------------------------

  Work on the property `should_exist` in `options`. The value may 
  be a file path or an array of file paths.

  The callback `succeed` is called if all of the provided paths 
  exists otherwise the callback `skip` is called with an error.

  ###
  should_exist: (options, skip, succeed) ->
    return succeed() unless options.should_exist?
    each(options.should_exist)
    .on 'item', (should_exist, next) ->
      fs.exists should_exist, (exists) ->
        if exists
        then next()
        else next new Error "File does not exist: #{should_exist}"
    .on 'error', (err) ->
      skip err
    .on 'end', succeed
  ###

  `should_not_exist` Ensure a file already exist
  ----------------------------------------------

  Work on the property `should_not_exist` in `options`. The value may 
  be a file path or an array of file paths.

  The callback `succeed` is called if none of the provided paths 
  exists otherwise the callback `skip` is called with an error.

  ###
  should_not_exist: (options, skip, succeed) ->
    return succeed() unless options.should_not_exist?
    each(options.should_not_exist)
    .on 'item', (should_not_exist, next) ->
      fs.exists should_not_exist, (exists) ->
        if exists
        then next new Error "File does not exist: #{should_not_exist}"
        else next()
    .on 'error', (err) ->
      skip err
    .on 'end', ->
      succeed()




