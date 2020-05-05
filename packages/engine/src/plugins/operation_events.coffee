
{EventEmitter} = require 'events'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/events'
  hooks:
    'nikita:session:action': (action) ->
      if action.parent
        action.operations ?= {}
        action.operations.events = action.parent.operations.events
      else
        action.operations ?= {}
        action.operations.events = new EventEmitter()
      action.operations.events.emit 'header', action.config.header if action.config.header
