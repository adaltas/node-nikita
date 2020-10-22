
{EventEmitter} = require 'events'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/events'
  hooks:
    'nikita:session:normalize': (action, handler) ->
      ->
        # Handler execution
        action = handler.apply null, arguments
        # Register function
        action.tools ?= {}
        action.tools.events = if action.parent
        then action.parent.tools.events
        else action.tools.events = new EventEmitter()
        action
    'nikita:session:action': (action) ->
      action.tools.events.emit 'nikita:action:start', action
    'nikita:session:result':
      after: '@nikitajs/engine/src/metadata/status'
      handler: ({action, error, output}, handler) ->
        ({action}) ->
          try
            output = await handler.apply null, arguments
            action.tools.events.emit 'nikita:action:end', action, null, output
            output
          catch err
            # console.log action
            action.tools.events.emit 'nikita:action:end', action, err, output
            throw err
    'nikita:session:resolved': ({action}) ->
      action.tools.events.emit 'nikita:session:resolved', ...arguments
    'nikita:session:rejected': ({action}) ->
      action.tools.events.emit 'nikita:session:rejected', ...arguments
      
