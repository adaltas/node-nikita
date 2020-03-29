
# Nikita

This is the main Nikita entry point. It expose a function to initialize a new
Nikita session.

## Dependencies

    require './register'
    registry = require './registry'
    session = require './session'

## Source Code

    module.exports = new Proxy session,
      get: (target, name) ->
        n = session()
        n[name]
