
utils = require '../../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/position'
  require: [
    '@nikitajs/core/src/plugins/history'
  ]
  hooks:
    'nikita:normalize':
      after: '@nikitajs/core/src/plugins/history'
      handler: (action, handler) ->
        ->
          action = await handler.call null, ...arguments
          action.metadata.depth = if action.parent then action.parent.metadata.depth + 1 else 0
          # plugins are not activated in the root session with {depth: 0}
          action.metadata.index = if action.siblings then action.siblings.length else 0
          action.metadata.position = if action.parent then action.parent.metadata.position.concat [action.metadata.index] else [0]
          action
    'nikita:action': (action) ->
      unless typeof action.metadata.depth is 'number'
        throw utils.error 'METADATA_DEPTH_INVALID_VALUE', [
          "configuration `depth` expect an integer value,"
          "got #{JSON.stringify action.metadata.depth}."
        ]
