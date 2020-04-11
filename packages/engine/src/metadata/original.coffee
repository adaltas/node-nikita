
array = require '../utils/array'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/original'
  hooks:
    'nikita:session:actions:arguments': ({args}, handler) ->
      ->
        actions = handler.apply null, arguments
        args = array.multiply ...args
        if Array.isArray actions
          actions.map (action,i) ->
            action.metadata.original = args[i]
            action
        else
          actions.metadata.original = args[0]
          actions
