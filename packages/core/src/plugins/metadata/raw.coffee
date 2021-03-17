
module.exports =
  name: '@nikitajs/core/src/plugins/metadata/raw'
  hooks:
    'nikita:registry:normalize': (action) ->
      # TODO: Validation
      action.metadata ?= {}
      action.metadata.raw ?= false
      action.metadata.raw_input ?= action.metadata.raw if action.metadata.raw
      action.metadata.raw_output ?= action.metadata.raw if action.metadata.raw
    'nikita:action': (action) ->
      action.metadata.raw ?= false
      action.metadata.raw_input ?= action.metadata.raw
      action.metadata.raw_output ?= action.metadata.raw
