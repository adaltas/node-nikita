
path = require 'path'

module.exports = (action_global, action_parent, options_action) ->
  action =
    metadata: {}
    options: {}
    original: (-> # Create original and filter with cascade
      options = options_action
      for k, v of action_parent?.metadata
        options[k] = v if options[k] is undefined and action_global.cascade[k] is true
      options
    )()
    parent: action_parent
  # Merge cascade action options with default session options
  action.metadata.cascade = {...action_global.cascade, ...options_action.cascade}
  # Copy initial options
  for k, v of options_action
    continue if k is 'cascade'
    action.metadata[k] = options_action[k]
  # Merge parent cascaded options
  for k, v of action_parent?.metadata
    continue unless action.metadata.cascade[k] is true
    action.metadata[k] = v if action.metadata[k] is undefined
  # Merge action options with default session options
  for k, v of action_global.options
    continue if k is 'cascade'
    action.metadata[k] = v if action.metadata[k] is undefined
  # Build headers option
  headers = []
  push_headers = (action) ->
    headers.push action.metadata.header if action.metadata.header
    push_headers action.parent if action.parent
  push_headers action
  action.metadata.headers = headers.reverse()
  # Default values
  action.metadata.sleep ?= 3000 # Wait 3s between retry
  action.metadata.retry ?= 0
  action.metadata.disabled ?= false
  action.metadata.status ?= true
  action.metadata.depth = if action.metadata.depth? then action.metadata.depth else (action.parent?.metadata?.depth or 0) + 1
  action.metadata.attempt = -1# Clone and filter cascaded options
  # throw Error 'Incompatible Options: status "false" implies shy "true"' if options.status is false and options.shy is false # Room for argument, leave it strict for now until we come accross a usecase justifying it.
  # options.shy ?= true if options.status is false
  action.metadata.shy ?= false
  # Goodies
  if action.metadata.source and match = /~($|\/.*)/.exec action.metadata.source
    unless action_global.store['nikita:ssh:connection']
    then action.metadata.source = path.join process.env.HOME, match[1]
    else action.metadata.source = path.posix.join '.', match[1]
  if action.metadata.target and match = /~($|\/.*)/.exec action.metadata.target
    unless action_global.store['nikita:ssh:connection']
    then action.metadata.target = path.join process.env.HOME, match[1]
    else action.metadata.target = path.posix.join '.', match[1]
  # Filter cascaded options
  for k, v of action.metadata
    continue if action.metadata.cascade[k] is false
    action.options[k] = v
  # Move handler and callback at root level
  action.handler = action.metadata.handler
  delete action.metadata.handler
  action.callback = action.metadata.callback
  delete action.metadata.callback
  action
