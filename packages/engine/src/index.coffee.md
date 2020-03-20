
# Nikita

This is the main Nikita entry point. It expose a function to initialize a new
Nikita session.

## Source Code

    module.exports = new Proxy (-> session arguments...),
      get: (target, name) ->
        return registry if name in ['registry']
        namespace = []
        namespace.push name
        on_call = ->
          unless registry.registered namespace
            throw Error "No action named #{namespace.join '.'}"
          session metadata: namespace: namespace, ...arguments
        on_get = (target, name) ->
          namespace.push name
          if not registry.registered(namespace, partial: true)
            namespace = []
            return undefined
          proxy
        new Proxy on_call, get: on_get

## Dependencies

    require './register'
    registry = require './registry'
    session = require './session'
