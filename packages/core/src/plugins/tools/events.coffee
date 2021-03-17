
{EventEmitter} = require 'events'

module.exports =
  name: '@nikitajs/core/src/plugins/tools/events'
  hooks:
    'nikita:normalize': (action, handler) ->
      ->
        # Handler execution
        action = await handler.apply null, arguments
        # Register function
        action.tools ?= {}
        action.tools.events = if action.parent
        then action.parent.tools.events
        else action.tools.events = new EventEmitter()
        action
    'nikita:action': (action) ->
      action.tools.events.emit 'nikita:action:start', action: action
    'nikita:result':
      after: '@nikitajs/core/src/plugins/output/status'
      handler: ({action, error, output}, handler) ->
        ({action}) ->
          try
            output = await handler.apply null, arguments
            action.tools.events.emit 'nikita:action:end',
              action: action
              error: undefined
              output: output
            output
          catch error
            action.tools.events.emit 'nikita:action:end',
              action: action
              error: error
              output: undefined
            throw error
    'nikita:resolved': ({action}) ->
      action.tools.events.emit 'nikita:resolved', ...arguments
    'nikita:rejected': ({action}) ->
      action.tools.events.emit 'nikita:rejected', ...arguments
      
