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
    
    module.exports = new Proxy (-> context arguments...),
      get: (target, name) ->
        ctx = context()
        ->
          return registry[name].apply registry, arguments if name in ['register', 'registered', 'unregister']
          ctx[name].apply ctx, arguments
      
## Dependencies
  
    context = require './context'
    registry = require './registry'
    
