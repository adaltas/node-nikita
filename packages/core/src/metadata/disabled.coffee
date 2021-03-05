
module.exports =
  name: '@nikitajs/core/src/metadata/disabled'
  hooks:
    'nikita:action': (action, handler) ->
      action.metadata.disabled ?= false
      if action.metadata.disabled then undefined else handler
