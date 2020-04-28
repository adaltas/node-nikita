
array = require '../utils/array'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/original'
  hooks:
    'nikita:session:arguments':
      before: '@nikitajs/engine/src/metadata/raw'
      handler: ({args, child}, handler) ->
        ->
          actions = handler.apply null, arguments
          args = unless child.metadata.raw_input
            array.multiply ...args
          else
            args
          if Array.isArray actions
            actions.map (action,i) ->
              action.metadata.original = args[i]
              action
          else
            actions.metadata.original = args[0]
            actions
