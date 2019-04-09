
path = require 'path'

module.exports = (action_global, action_parent, options_action) ->
  action =
    internal: {}
    options: {}
    original: (-> # Create original and filter with cascade
      options = options_action
      for k, v of action_parent?.internal
        options[k] = v if options[k] is undefined and action_global.cascade[k] is true
      options
    )()
    parent: action_parent
  # Merge cascade action options with default session options
  action.internal.cascade = {...action_global.cascade, ...options_action.cascade}
  # Copy initial options
  for k, v of options_action
    continue if k is 'cascade'
    action.internal[k] = options_action[k]
  # Merge parent cascaded options
  for k, v of action_parent?.internal
    continue unless action.internal.cascade[k] is true
    action.internal[k] = v if action.internal[k] is undefined
  # Merge action options with default session options 
  for k, v of action_global.options
    continue if k is 'cascade'
    action.internal[k] = v if action.internal[k] is undefined
  # Build headers option
  headers = []
  push_headers = (action) ->
    headers.push action.internal.header if action.internal.header
    push_headers action.parent if action.parent
  push_headers action
  action.internal.headers = headers.reverse()
  # Default values
  action.internal.sleep ?= 3000 # Wait 3s between retry
  action.internal.retry ?= 0
  action.internal.disabled ?= false
  action.internal.status ?= true
  action.internal.depth = if action.internal.depth? then action.internal.depth else (action.parent?.internal?.depth or 0) + 1
  action.internal.attempt = -1# Clone and filter cascaded options
  # throw Error 'Incompatible Options: status "false" implies shy "true"' if options.status is false and options.shy is false # Room for argument, leave it strict for now until we come accross a usecase justifying it.
  # options.shy ?= true if options.status is false
  action.internal.shy ?= false
  # Goodies
  if action.internal.source and match = /~($|\/.*)/.exec action.internal.source
    unless action_global.store['nikita:ssh:connection']
    then action.internal.source = path.join process.env.HOME, match[1]
    else action.internal.source = path.posix.join '.', match[1]
  if action.internal.target and match = /~($|\/.*)/.exec action.internal.target
    unless action_global.store['nikita:ssh:connection']
    then action.internal.target = path.join process.env.HOME, match[1]
    else action.internal.target = path.posix.join '.', match[1]
  # Filter cascaded options
  for k, v of action.internal
    continue if action.internal.cascade[k] is false
    action.options[k] = v
  # Move handler and callback at root level
  action.handler = action.internal.handler
  delete action.internal.handler
  action.callback = action.internal.callback
  delete action.internal.callback
  action
