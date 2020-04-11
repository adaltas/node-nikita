
module.exports = ->
  module: '@nikitajs/engine/src/metadata/disabled'
  hooks:
    'nikita:session:normalize': (action) ->
      # Move property from action to metadata
      if action.hasOwnProperty 'disabled'
        action.metadata.disabled = action.disabled
        delete action.disabled
    'nikita:session:action': (action, handler) ->
      action.metadata.disabled ?= false
      if action.metadata.disabled then (->) else handler
