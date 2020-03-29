
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
    run = switch typeof action.conditions.if
      when 'undefined'
        false
      when 'boolean'
        action.conditions.if
      when 'number'
        !!action.conditions.if
      when 'string'
        action.conditions.if.length
      when 'object'
        if Buffer.isBuffer action.conditions.if
          action.conditions.if.length
        else if Array.isArray action.conditions.if
          action.conditions.if.length
        else if action.conditions.if is null
          false
        else
          Object.keys(action.conditions.if).length
      when 'function'
        await session null, ({run}) ->
          run
            metadata:
              condition: true
              depth: action.metadata.depth
            parent: action
            handler: action.conditions.if
            options: action.options
    if run then handler else (->)
  
