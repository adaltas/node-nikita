

###
The `argument` plugin map an argument which is not an object into a configuration property.

###

module.exports =
  name: '@nikitajs/core/src/plugins/metadata/argument_to_config'
  hooks:
    'nikita:action':
      handler: (action) ->
        if action.metadata.argument_to_config
          action.config[action.metadata.argument_to_config] ?= action.metadata.argument
