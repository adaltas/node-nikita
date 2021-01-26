
templated = require 'self-templated'

module.exports =
  module: '@nikitajs/engine/src/plugins/templated'
  hooks:
    'nikita:session:normalize': (action) ->
      action.metadata.templated ?= true
    'nikita:session:action': (action) ->
      if action.metadata.templated isnt false and action.parent?.metadata.templated isnt false
        templated action,
          array: true
          compile: false
          mutate: true
          partial:
            metadata: true
            config: true
