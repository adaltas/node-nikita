
session = require '../session'

module.exports = ({}) ->
  'nikita:session:handler:call': ({action}, handler) ->
    return handler unless action.options.hasOwnProperty('if')
    return (->) unless action.options.if?
    # return handler unless action.options.if?
    if action.options.if is false or action.options.if is ''
      return (->)
    if typeof action.options.if is 'number'
      return if action.options.if then handler else (->)
    if Buffer.isBuffer action.options.if
      console.log 'vuffer', action.options.if.length
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
  
