
os = require 'os'
path = require 'path'

module.exports =
  name: '@nikitajs/core/src/plugins/tools_path'
  hooks:
    'nikita:action':
      after: '@nikitajs/core/src/plugins/ssh'
      handler: (action) ->
        action.tools ?= {}
        # Path is alwaws posix over ssh
        # otherwise it is platform dependent
        action.tools.path = unless action.ssh
          if os.platform is 'win32'
          then path.win32
          else path.posix
        else
          path.posix
        # Reinject posix and win32 path for conveniency
        action.tools.path.posix = path.posix
        action.tools.path.win32 = path.win32
