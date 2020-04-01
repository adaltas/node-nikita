
# Nikita

# This is the main Nikita entry point. It expose a function to initialize a new
# Nikita session.

# Dependencies

require './register'
session = require './session'
  
create = ->
  session plugins: [
    require './plugins/conditions'
    require './plugins/schema'
    require './plugins/disabled'
    require './plugins/retry'
  ], ...arguments

# Source Code

module.exports = new Proxy create,
  get: (target, name) ->
    create()[name]
