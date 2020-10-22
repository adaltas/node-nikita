

###
The `global` plugin look it the parent tree for a "global" configuration. If
found, it will merge its value with the current configuration.

The functionnality is used to provide global default settings to a group of
actions. Consider for exemple the Docker actions. Each action has specific
configuration properties but there are also some properties which benefits
from being shared by all the Docker actions such as the adress of the Docker
daemon if it is not run locally.

###

module.exports = ->
  module: '@nikitajs/engine/src/plugins/global'
  require: [
    '@nikitajs/engine/src/plugins/operation_find'
  ]
  hooks:
    'nikita:registry:normalize':
      handler: (action) ->
        if action.hasOwnProperty 'global'
          action.metadata.global = action.global
          delete action.global
    'nikita:session:normalize':
      handler: (action) ->
        if action.hasOwnProperty 'global'
          action.metadata.global = action.global
          delete action.global
    'nikita:session:action':
      handler: (action) ->
        global = action.metadata.global
        return action unless global
        action.config[global] = await action.tools.find ({config}) -> config[global]
        action.config[k] ?= v for k, v of action.config[global]
        delete action.config[global]
        action
