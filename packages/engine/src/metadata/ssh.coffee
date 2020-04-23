
{merge} = require 'mixme'
utils = require '../utils'
session = require '../session'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/ssh'
  hooks:
    'nikita:session:normalize': (action, handler) ->
      # Dont interfere with ssh actions
      return handler if action.metadata.namespace[0] is 'ssh'
      if action.hasOwnProperty 'ssh'
        ssh = action.ssh
        delete action.ssh
      ->
        action = handler.call null, ...arguments
        action.ssh = ssh
        action
    'nikita:session:action': (action, handler) ->
      # return handler if action.metadata.namespace[0] is 'ssh'
      ssh = await action.operations.find (action) ->
        action.ssh
      if ssh and not utils.ssh.is ssh
        dispose = true
        {ssh} = await session ({run}) -> run
          metadata:
            namespace: ['ssh', 'open']
          config: ssh
      action.ssh = ssh
      ->
        output = handler.apply null, arguments
        if dispose
          await session ({run}) -> run
            metadata:
              namespace: ['ssh', 'close']
            config: ssh: ssh
        output
