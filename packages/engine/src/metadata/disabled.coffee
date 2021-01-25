
module.exports =
  module: '@nikitajs/engine/src/metadata/disabled'
  hooks:
    'nikita:session:action': (action, handler) ->
      action.metadata.disabled ?= false
      if action.metadata.disabled then (->) else handler
