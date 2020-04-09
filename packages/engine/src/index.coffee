
# Nikita

# This is the main Nikita entry point. It expose a function to initialize a new
# Nikita session.

require './register'
session = require './session'
  
create = ->
  session plugins: [
    require './metadata/raw'
    require './metadata/original'
    require './metadata/depth'
    require './plugins/history'
    require './metadata/status'
    require './plugins/conditions'
    require './plugins/schema'
    require './metadata/disabled'
    require './metadata/relax'
    require './metadata/retry'
  ], ...arguments

module.exports = new Proxy create,
  get: (target, name) ->
    create()[name]
