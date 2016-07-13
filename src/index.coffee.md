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
        # return target[name] if target[name]
        ctx = context()
        tree = []
        tree.push name
        builder = ->
          return registry[name].apply registry, arguments if name in ['register', 'registered', 'unregister']
          a = ctx[tree.shift()]
          return a unless typeof a is 'function'
          while name = tree.shift()
            a[name]
          a.apply ctx, arguments
        proxy = new Proxy builder,
          get: (target, name) ->
            # return target[name] if name in target
            tree.push name
            # Fallback to standard object behavior unless in registry
            # cnames = registry
            # for n, i in tree
            #   return cnames[n] unless cnames[n]?
            #   cnames = cnames[n]
            proxy
        proxy
## Dependencies
  
    context = require './context'
    registry = require './registry'
    
