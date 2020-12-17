
# Nikita

# This is the main Nikita entry point. It expose a function to initialize a new
# Nikita session.

require './register'
session = require './session'
  
create = ->
  session plugins: [
    require './metadata/debug'
    require './metadata/depth'
    require './metadata/disabled'
    require './metadata/raw'
    require './metadata/relax'
    require './metadata/retry'
    require './metadata/status'
    require './metadata/tmpdir'
    require './metadata/uuid'
    require './plugins/args'
    require './plugins/argument'
    require './plugins/conditions'
    require './plugins/conditions_execute'
    require './plugins/conditions_exists'
    require './plugins/conditions_os'
    require './plugins/global'
    require './plugins/history'
    require './plugins/output_logs'
    require './plugins/schema'
    require './plugins/ssh'
    require './plugins/templated'
    require './plugins/tools_dig'
    require './plugins/tools_events'
    require './plugins/tools_find'
    require './plugins/tools_log'
    require './plugins/tools_path'
    require './plugins/tools_walk'
  ], ...arguments

module.exports = new Proxy create,
  get: (target, name) ->
    create()[name]
