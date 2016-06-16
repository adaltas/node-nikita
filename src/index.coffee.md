# Mecano

Mecano gather a set of functions usually used during system deployment. All the
functions share a common API with flexible options.

*   Run actions both locally and remotely over SSH.
*   Ability to see if an action had an effect through the second argument
    provided in the callback.
*   Common API with options and callback arguments and calling the callback with
    an error and the number of affected actions.
*   Run one or multiple actions depending on option argument being an object or
    an array of objects.

## Source Code
    
    module.exports = ->
      context arguments...
  
## Dependencies
  
    context = require './context'

## Register functions

Register a new function available when requiring mecano and inside any mecano
instance. 

You can also un-register a existing function by passing "null" or "false" as
the second argument. It will return "true" if the function is un-registered or
"false" if there was nothing to do because the function wasn't already
registered.

    registry = require './misc/registry'
    do ->
      module.exports.register = (name, handler) ->
        if handler is null or handler is false
          delete module.exports[name] if module.exports[name]
          registry.register name, handler
          return module.exports
        registry.register name, handler
        Object.defineProperty module.exports, name, 
          configurable: true
          get: -> context()[name]
      
      module.exports.registered = registry.registered

      # Pre-register mecano internal functions
      for name, _ of registry then do (name) ->
        Object.defineProperty module.exports, name, 
          configurable: true
          get: -> context()[name]
        
      for name in ['end', 'call', 'before', 'after', 'then', 'on'] then do (name) ->
        module.exports[name] = ->
          obj = context()
          obj[name].apply obj, arguments
