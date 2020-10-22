
{merge} = require 'mixme'
utils = require '../utils'
session = require '../session'

###
Pass an SSH connection or SSH information to an action. Disable SSH if the value
is `null` or `false`. 
###

module.exports = ->
  module: '@nikitajs/engine/src/metadata/ssh'
  require: [
    '@nikitajs/engine/src/plugins/operation_find'
  ]
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
      ssh = await action.tools.find (action) ->
        return undefined if action.ssh is undefined
        action.ssh or false
      if ssh and not utils.ssh.is ssh
        {ssh} = await session ({run}) -> run
          metadata:
            namespace: ['ssh', 'open']
          config: ssh
        action.metadata.ssh_dispose = true
      else if ssh is false
        ssh = null
      action.ssh = ssh
      handler
    'nikita:session:result': ({action}) ->
      if action.metadata.ssh_dispose
        await session ({run}) -> run
          metadata:
            namespace: ['ssh', 'close']
          config: ssh: action.ssh
