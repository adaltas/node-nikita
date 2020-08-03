
templated = require 'self-templated'

module.exports = ->
  module: '@nikitajs/engine/src/plugins/template'
  hooks:
    'nikita:session:action': (action, handler) ->
      ->
        if action.metadata.templated isnt false and action.parent?.metadata.templated isnt false
          action = templated action,
            compile: false
            partial:
              metadata: true
              config: true
        handler.call null, action
