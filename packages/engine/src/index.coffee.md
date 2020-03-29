
# Nikita

This is the main Nikita entry point. It expose a function to initialize a new
Nikita session.

## Dependencies

    require './register'
    registry = require './registry'
    conditions = require './plugins/conditions'
    schema = require './plugins/schema'
    run = require './session'
      
    session = ->
      run null, plugins: [
        conditions
        schema
      ], ...arguments

## Source Code

    module.exports = new Proxy session,
      get: (target, name) ->
        n = session()
        n[name]
