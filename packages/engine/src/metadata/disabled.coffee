
module.exports =
  name: '@nikitajs/engine/src/metadata/disabled'
  hooks:
    'nikita:session:action': (action, handler) ->
      action.metadata.disabled ?= false
      if action.metadata.disabled then null else handler
