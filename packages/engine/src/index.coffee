
# Nikita

# This is the main Nikita entry point. It expose a function to initialize a new
# Nikita session.

require './register'
session = require './session'
  
create = ->
  session plugins: [
    require './plugins/original'
    require './plugins/depth'
    require './plugins/status'
    require './plugins/conditions'
    require './plugins/schema'
    require './plugins/disabled'
    require './plugins/relax'
    require './plugins/retry'
  ], ...arguments

module.exports = new Proxy create,
  get: (target, name) ->
    create()[name]
