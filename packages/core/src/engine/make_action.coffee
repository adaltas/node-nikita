
path = require 'path'

module.exports = (action_global, action_parent, options_action) ->
  # Merge cascade action options with default session options
  cascade = {
    ...action_global.cascade
    ...(action_parent?.cascade or {})
    ...options_action.cascade
  }
  action =
    action: options_action.action
    args: null
    callback: options_action.callback
    cascade: cascade
    error: null
    error_in_callback: null
    handler: options_action.handler
    metadata: {}
    options: {}
    original: (-> # Create original and filter with cascade
      options = options_action
      for k, v of action_parent?.metadata
        options[k] = v if options[k] is undefined and action_global.cascade[k] is true
      options
    )()
    output: null
    parent: action_parent
    session: null
  # Copy initial options
  for k, v of options_action
    continue if k is 'action'
    continue if k is 'cascade'
    continue if k is 'handler'
    continue if k is 'callback'
    if metadata[k] isnt undefined
      action.metadata[k] = v
    else
      continue if action.cascade[k] is false
      action.options[k] = v
  # Merge parent cascaded options
  for k, v of action_parent?.metadata
    continue unless action.cascade[k] is true
    action.metadata[k] = v if action.metadata[k] is undefined
  for k, v of action_parent?.options
    continue unless action.cascade[k] is true
    action.options[k] = v if action.options[k] is undefined
  # Merge action options with default session options
  # All options are merge
  for k, v of action_global.options
    continue if k is 'cascade'
    action.options[k] = v if action.options[k] is undefined
  # Build headers option
  headers = []
  push_headers = (action) ->
    headers.push action.metadata.header if action.metadata.header
    push_headers action.parent if action.parent
  push_headers action
  action.metadata.headers = headers.reverse()
  # Default values
  action.metadata.debug ?= false
  action.metadata.deprecate ?= false
  action.metadata.sleep ?= 3000 # Wait 3s between retry
  action.metadata.retry ?= 0
  action.metadata.disabled ?= false
  action.metadata.status ?= true
  action.metadata.depth = if action.metadata.depth? then action.metadata.depth else (action.parent?.metadata?.depth or 0) + 1
  action.metadata.attempt = -1 # Clone and filter cascaded options
  action.metadata.shy ?= false
  # Goodies
  if action.options.source and match = /~($|\/.*)/.exec action.options.source
    unless action_global.store['nikita:ssh:connection']
    then action.options.source = path.join process.env.HOME, match[1]
    else action.options.source = path.posix.join '.', match[1]
  if action.options.target and match = /~($|\/.*)/.exec action.options.target
    unless action_global.store['nikita:ssh:connection']
    then action.options.target = path.join process.env.HOME, match[1]
    else action.options.target = path.posix.join '.', match[1]
  action

metadata = module.exports.metadata =
  after: null
  argument: null
  attempt: -1
  before: null
  cascade: {}
  debug: false
  deprecate: false
  depth: 0
  disabled: false
  get: false
  header: []
  log: null
  once: false
  relax: false
  retry: 0
  schema: null
  shy: false
  sleep: 3000
  status: true
  tolerant: false
