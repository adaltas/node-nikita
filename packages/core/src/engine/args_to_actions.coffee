
registry = require '../registry'
array = require '../misc/array'
path = require 'path'

module.exports = (action_global, _arguments, action_name) ->
  _arguments = [{}] if _arguments.length is 0
  # Convert every argument to an array
  for args, i in _arguments
    _arguments[i] = [args] unless Array.isArray args
  # Get middleware
  middleware = action_global.registry.get(action_name) or registry.get(action_name) if Array.isArray(action_name)
  # Multiply arguments
  actions = null
  for __arguments, i in _arguments
    newactions = for __argument, j in __arguments
      if i is 0
        [[middleware, __argument]]
      else
        for action, i in actions
          [action..., __argument]
    actions = array.flatten newactions, 0
  # Load module
  unless middleware
    for action in actions
      middleware = null
      for option in action
        if typeof option is 'string'
          middleware = option
          middleware = path.resolve process.cwd(), option if option.substr(0, 1) is '.'
          middleware = require.main.require middleware
      action.unshift middleware if middleware
  # Build actions
  actions = for action in actions
    newaction = {}
    for opt in action
      continue unless action?
      if typeof opt is 'string'
        if not newaction.argument
          opt = argument: opt
        else
          throw Error 'Invalid option: encountered a string while argument is already defined'
      if typeof opt is 'function'
        # todo: handler could be registed later by an external module,
        # in such case, the user provided function should be interpreted
        # as a callback
        if not newaction.handler
          opt = handler: opt
        else if not newaction.callback
          opt = callback: opt
        else
          throw Error 'Invalid option: encountered a function while both handler and callback options are defined.'
      if typeof opt isnt 'object'
        opt = argument: opt
      for k, v of opt
        continue if newaction[k] isnt undefined and v is undefined
        newaction[k] = v
    newaction
  # Normalize
  actions = for action in actions
    action.action = action_name if action_name
    action.action = [action.action] unless Array.isArray action.action
    action.once = ['handler'] if action.once is true
    delete action.once if action.once is false
    action.once = action.once.sort() if Array.isArray action.once
    action.once = action.once.sort() if Array.isArray action.once
    action
  actions
