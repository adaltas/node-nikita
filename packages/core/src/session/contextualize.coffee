
{mutate, is_object_literal} = require 'mixme'
utils = require '../utils'

module.exports = (args) ->
  args_is_array = args.some (arg) -> Array.isArray arg
  # Multiply the arguments
  actions = utils.array.multiply ...args
  # Reconstituate the action
  default_action = ->
    config: {}
    metadata: {}
    hooks: {}
    state: {}
  new_actions = for action in actions
    new_action = default_action()
    for arg in action then switch typeof arg
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
        else if is_object_literal arg
          for k, v of arg
            if k is '$'
              mutate new_action, v
            else if k[0] is '$'
              if k is '$$'
                mutate new_action.metadata, v
              else
                prop = k.substr 1
                if prop in properties
                  new_action[prop] = v
                else
                  new_action.metadata[prop] = v
            else
              new_action.config[k] = v unless v is undefined
        else
          mutate new_action, metadata: argument: arg
      else
        mutate new_action, metadata: argument: arg
    new_action
  # Create empty action when no arguments are provided and not for an empty array
  new_actions = default_action() if not args.length
  if args_is_array then new_actions else new_actions[0]

properties = [
  'context'
  'handler'
  'hooks'
  'metadata'
  'config'
  'parent'
  'plugins'
  'registry'
  'run'
  'scheduler'
  'ssh'
  'state'
]
