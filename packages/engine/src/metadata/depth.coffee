
utils = require '../utils'

module.exports = ->
  module: '@nikitajs/engine/src/metadata/depth'
  hooks:
    'nikita:session:normalize': (action) ->
      action.metadata.depth = if action.parent then action.parent.metadata.depth + 1 else 0
    'nikita:session:action': (action) ->
      # action.metadata.depth ?= 0
      unless typeof action.metadata.depth is 'number'
        throw utils.error 'METADATA_DEPTH_INVALID_VALUE', [
          "configuration `depth` expect an integer value,"
          "got #{JSON.stringify action.metadata.depth}."
        ]
