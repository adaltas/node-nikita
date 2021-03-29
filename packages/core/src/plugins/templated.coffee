
selfTemplated = require 'self-templated'

module.exports =
  name: '@nikitajs/core/src/plugins/templated'
  hooks:
    'nikita:action':
      after: [
        '@nikitajs/core/src/plugins/metadata/schema'
        # '@nikitajs/core/src/plugins/metadata/tmpdir'
      ]
      handler: (action) ->
        templated = await action.tools.find (action) -> action.metadata.templated
        return if templated is false
        selfTemplated action,
          array: true
          compile: false
          mutate: true
          partial:
            assertions: true
            conditions: true
            config: true
            metadata: true
