
os = require 'os'
path = require 'path'

module.exports = (action) ->
  module: '@nikitajs/engine/src/plugins/operation_path'
  require: '@nikitajs/engine/src/metadata/ssh'
  hooks:
    'nikita:session:action':
      # after: '@nikitajs/engine/src/metadata/ssh'
      handler: (action, handler) ->
        action.operations ?= {}
        # Path is alwaws posix over ssh
        # otherwise it is platform dependent
        action.operations.path = unless action.ssh
          if os.platform is 'win32'
          then path.win32
          else path.posix
        else
          path.posix
        # Reinject posix and win32 path for conveniency
        action.operations.path.posix = path.posix
        action.operations.path.win32 = path.win32
        handler
