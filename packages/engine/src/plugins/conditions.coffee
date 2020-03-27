
session = require '../session'

module.exports = ({}) ->
  'nikita:session:normalize:user': (args, handler) ->
    return handler
    # Ventilate conditions properties defined at root
    new_action = {}
    new_action.conditions = {}
    for property, value of args.action
      if /^(if|unless)($|_[\w_]+$)/.test property
        throw Error 'CONDITIONS_DUPLICATED_DECLARATION', [
          "Property #{property} is defined multiple times,"
          'at the root of the action and inside conditions'
        ] if new_action.conditions[property]
        new_action.conditions[property] = value
      else
        new_action[property] = value
    # (args, handler) ->
    #   args.action = new_action
    #   handler.call null, args, handler
    ->
      # console.log 'handler', handler
      console.log '>>>', new_action.conditions
      args.action = new_action
      handler.call null, args, handler
  'nikita:session:handler:call': ({action}, handler) ->
    return handler unless action.options.hasOwnProperty('if')
    return (->) unless action.options.if?
    # return handler unless action.options.if?
    if action.options.if is false or action.options.if is ''
      return (->)
    if typeof action.options.if is 'number'
      return if action.options.if then handler else (->)
    if Buffer.isBuffer action.options.if
      return if action.options.if.length then handler else (->)
    return handler if action.options.if is true
    res = await action.run
      metadata:
        condition: true
        depth: action.metadata.depth
      options: action.options
      parent: action
      handler: action.options.if
    handler
  
