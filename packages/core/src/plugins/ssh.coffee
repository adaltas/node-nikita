
{merge} = require 'mixme'
utils = require '../utils'
session = require '../session'

###
Pass an SSH connection or SSH information to an action. Disable SSH if the value
is `null` or `false`.
###

module.exports =
  name: '@nikitajs/core/src/plugins/ssh'
  require: [
    '@nikitajs/core/src/plugins/tools_find'
  ]
  hooks:
    'nikita:normalize': (action, handler) ->
      # Dont interfere with ssh actions
      return handler if action.metadata.namespace[0] is 'ssh'
      if action.hasOwnProperty 'ssh'
        ssh = action.ssh
        delete action.ssh
      ->
        action = await handler.call null, ...arguments
        action.ssh = ssh
        action
    'nikita:action': (action) ->
      # return handler if action.metadata.namespace[0] is 'ssh'
      ssh = await action.tools.find (action) ->
        return undefined if action.ssh is undefined
        action.ssh = null if action.ssh is false
        action.ssh
      if ssh and not utils.ssh.is ssh
        {ssh} = await session
          plugins: [ # Need to inject `tools.log`
            require '../plugins/tools_events'
            require '../plugins/tools_log'
            require '../metadata/status'
            require '../plugins/history'
          ]
        .ssh.open config: ssh
        action.metadata.ssh_dispose = true
        action.ssh = ssh
      else if ssh
        action.ssh = ssh
    'nikita:result': ({action}) ->
      if action.metadata.ssh_dispose
        await session
          plugins: [ # Need to inject `tools.log`
            require '../plugins/tools_events'
            require '../plugins/tools_log'
            require '../metadata/status'
            require '../plugins/history'
          ]
        .ssh.close ssh: action.ssh
