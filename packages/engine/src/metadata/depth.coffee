
error = require '../utils/error'

module.exports = ->
  name: 'metadata_depth'
  hooks:
    'nikita:session:normalize': (action) ->
      # Move property from action to metadata
      if action.hasOwnProperty 'depth'
        action.metadata.depth = action.depth
        delete action.depth
      action.metadata.depth = if action.parent then action.parent.metadata.depth + 1 else 0
    'nikita:session:action': (action) ->
      # action.metadata.depth ?= 0
      unless typeof action.metadata.depth is 'number'
        throw error 'METADATA_DEPTH_INVALID_VALUE', [
          "option `depth` expect an integer value,"
          "got #{JSON.stringify action.metadata.depth}."
        ]
