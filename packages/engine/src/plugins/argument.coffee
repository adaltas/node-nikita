

###
The `argument` plugin map an argument which is not an object into a configuration property.

###

module.exports = ->
  module: '@nikitajs/engine/src/plugins/argument'
  hooks:
    'nikita:session:normalize':
      handler: (action) ->
        if action.hasOwnProperty 'argument'
          action.metadata.argument_name = action.argument
          delete action.argument
    'nikita:session:action':
      handler: (action) ->
        if action.metadata.argument_name
          action.config[action.metadata.argument_name] ?= action.metadata.argument
        action
