

each = require 'each'
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
  [goptions, options, callback] = misc.args args
  isArray = Array.isArray options
  # Pass user arguments
  user_args = []
  result = child()
  # Handling modification count
  modified = 0
  finish = (err) ->
    unless isArray then user_args = for arg, i in user_args
      user_args[i] = arg[0]
    callback err, modified, user_args... if callback
    result.end err, modified, user_args...
  # Normalize options
  misc.options options, (err, options) ->
    return finish err if err
    # Run multiple actions sequentially or concurrently
    each( options )
    .parallel(goptions.parallel)
    .on 'item', (options, next) ->
      # Handle conditions
      conditions.all options, next, ->
        handler options, (err, modif, args...) ->
          return next err if err
          modified++ if modif
          for arg, i in args
            user_args[i] ?= []
            user_args[i].push arg
          next()
    .on 'both', (err) ->
      finish err
  # Return a Mecano Child instance
  result
