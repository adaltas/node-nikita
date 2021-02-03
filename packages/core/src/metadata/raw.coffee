
module.exports =
  name: '@nikitajs/core/src/metadata/raw'
  hooks:
    'nikita:registry:normalize': (action) ->
      action.metadata ?= {}
      action.metadata.raw ?= false
      action.metadata.raw_input ?= action.metadata.raw
      action.metadata.raw_output ?= action.metadata.raw
    'nikita:session:action': (action) ->
      action.metadata.raw ?= false
      action.metadata.raw_input ?= action.metadata.raw
      action.metadata.raw_output ?= action.metadata.raw
