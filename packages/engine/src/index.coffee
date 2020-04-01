
# Nikita

# This is the main Nikita entry point. It expose a function to initialize a new
# Nikita session.

# Dependencies

require './register'
conditions = require './plugins/conditions'
schema = require './plugins/schema'
disabled = require './plugins/disabled'
session = require './session'
  
create = ->
  session plugins: [
    conditions
    schema
    disabled
  ], ...arguments

# Source Code

module.exports = new Proxy create,
  get: (target, name) ->
    create()[name]
