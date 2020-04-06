
{mutate} = require 'mixme'
{multiply} = require '../utils/array'

module.exports = (args) ->
  args_is_array = args.some (arg) -> Array.isArray arg
  # Multiply the arguments
  actions = multiply ...args
  # Reconstituate the action
  new_actions = for action in actions
    new_action = {}
    for arg in action
      switch typeof arg
        when 'function'
          throw Error 'Invalid Action Argument: handler is already registered, got a function' if action.handler
          mutate new_action, handler: arg
        when 'string'
          throw Error "Invalid Action Argument: handler is already registered, got #{JSON.stringigy arg}" if action.handler
          mutate new_action, metadata: argument: arg
        when 'object'
          throw Error "Invalid Action argument: argument cannot be an array, got #{JSON.stringify arg}" if Array.isArray arg
          if arg is null
            mutate new_action, metadata: argument: null
          else
            mutate new_action, arg
        else
          mutate new_action, metadata: argument: arg
    new_action
  if args_is_array then new_actions else new_actions[0]
