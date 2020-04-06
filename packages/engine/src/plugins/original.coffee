
session = require '../session'
array = require '../utils/array'

module.exports = ->
  'nikita:session:actions:arguments': ({args}, handler) ->
    ->
      actions = handler.apply null, handler
      args = array.multiply ...args
      # console.log ':multiply:', args, test #JSON.stringify test, null, 2
      actions.map (action,i) ->
        action.metadata.original = args[i]
      actions
