
# Nikita

This is the main Nikita entry point. It expose a function to initialize a new
Nikita session.

## Source Code

    module.exports = new Proxy (-> session arguments...),
      get: (target, name) ->
        return registry if name in ['registry']
        ctx = session()
        return undefined unless ctx[name]
        return ctx[name] if name in ['cascade']
        tree = []
        tree.push name
        builder = ->
          a = ctx[tree.shift()]
          return a unless typeof a is 'function'
          while name = tree.shift()
            a[name]
          a.apply ctx, arguments
        proxy = new Proxy builder,
          get: (target, name) ->
            tree.push name
            if not registry.registered(tree, partial: true)
              tree = []
              return undefined
            proxy
        proxy

## Dependencies

    # require './register'
    session = require './session'
    registry = require './registry'
