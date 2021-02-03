
module.exports =
  name: '@nikitajs/core/src/metadata/disabled'
  hooks:
    'nikita:session:action': (action, handler) ->
      action.metadata.disabled ?= false
      if action.metadata.disabled then null else handler
