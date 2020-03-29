
session = require '../session'

# condition_if: (value)

module.exports = ({}) ->
  'nikita:session:normalize:user': (args, handler) ->
    # return handler
    # Ventilate conditions properties defined at root
    new_action = {}
    conditions = {}
    for property, value of args.action
      if /^(if|unless)($|_[\w_]+$)/.test property
        throw Error 'CONDITIONS_DUPLICATED_DECLARATION', [
          "Property #{property} is defined multiple times,"
          'at the root of the action and inside conditions'
        ] if conditions[property]
        conditions[property] = value
      else
        new_action[property] = value
    ->
      arguments[0].action = new_action
      action = handler.call null, ...arguments
      action.conditions = conditions
      action
  'nikita:session:handler:call': ({action}, handler) ->
    return handler unless action.conditions.hasOwnProperty('if')
    return (->) unless action.conditions.if?
    # return handler unless action.conditions.if?
    if action.conditions.if is false or action.conditions.if is ''
      return (->)
    if typeof action.conditions.if is 'number'
      return if action.conditions.if then handler else (->)
    if typeof action.conditions.if is 'string'
      return if action.conditions.if.length then handler else (->)
    if Buffer.isBuffer action.conditions.if
      return if action.conditions.if.length then handler else (->)
    return handler if action.conditions.if is true
    res = await session null, ({run}) ->
      run
        metadata:
          condition: true
          depth: action.metadata.depth
        parent: action
        handler: action.conditions.if
        options: action.options
    if res then handler else (->)
  
