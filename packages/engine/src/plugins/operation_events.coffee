
{EventEmitter} = require 'events'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/events'
  hooks:
    'nikita:session:normalize': (action, handler) ->
      ->
        # Handler execution
        action = handler.apply null, arguments
        # Register function
        action.operations ?= {}
        action.operations.events = if action.parent
        then action.parent.operations.events
        else action.operations.events = new EventEmitter()
        action
    'nikita:session:action': (action) ->
      action.operations.events.emit 'nikita:action:start', action
    'nikita:session:result':
      after: '@nikitajs/engine/src/metadata/status'
      handler: ({action, error, output}, handler) ->
        # console.log 'operation:event', arguments
        # action.operations.events.emit 'nikita:action:end', action, error, output
        ({action}) ->
          try
            output = await handler.apply null, arguments
            action.operations.events.emit 'nikita:action:end', action, null, output
            output
          catch err
            # console.log action
            action.operations.events.emit 'nikita:action:end', action, err, output
            throw err
    'nikita:session:resolved': ({action}) ->
      action.operations.events.emit 'nikita:session:resolved', ...arguments
    'nikita:session:rejected': ({action}) ->
      action.operations.events.emit 'nikita:session:rejected', ...arguments
      
