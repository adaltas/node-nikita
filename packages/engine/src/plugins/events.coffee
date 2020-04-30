
{EventEmitter} = require 'events'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/events'
  hooks:
    'nikita:session:action': (action) ->
      if action.parent
        action.events = action.parent.operations.events
      else
        action.operations ?= {}
        action.operations.events = new EventEmitter()
