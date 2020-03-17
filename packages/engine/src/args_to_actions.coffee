
{is_object, mutate} = require 'mixme'
array = require './misc/array'

module.exports = (args) ->
  actions = multiply args
  actions = for action in actions
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

module.exports.multiply = multiply = (args) ->
  # Convert every argument to an array
  for arg, i in args
    args[i] = [arg] unless Array.isArray arg
  # Multiply arguments
  actions = []
  for arg, i in args
    newactions = for arg_element, j in arg
      # Every element of the first argument will initialize actions
      if i is 0
        [[arg_element]]
      else
        for action, i in actions
          [action..., arg_element]
    actions = array.flatten newactions, 0
  actions
  
