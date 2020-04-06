
{is_object, merge, mutate} = require 'mixme'
{multiply} = require './utils/array'

module.exports.build = (args) ->
  # Multiply the arguments
  actions = multiply ...args
  # Reconstituate the action
  for action in actions
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

module.exports.normalize = normalize = (action) ->
  if Array.isArray action
    return action.map (action) -> normalize action
  new_action =
    metadata: action.metadata or {}
    options: action.options or {}
    hooks: action.hooks or {}
  if action.namespace
    action.metadata.namespace = action.namespace
    delete action.namespace
  for property, value of action
    if property is 'metadata'
      continue # Already merged before
    else if property is 'options'
      continue # Already merged before
    else if property is 'hooks'
      continue # Already merged before
    else if property in properties
      new_action[property] = value
    else if /^on_/.test property
      new_action.hooks[property] = value
    else
      new_action.options[property] = value
  new_action

properties = [
  'context'
  'handler'
  'hooks'
  'metadata'
  'parent'
  'registry'
  'options'
  'plugins'
  'scheduler'
  'state'
  'run'
]
