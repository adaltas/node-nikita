
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

module.exports.normalize = (actions) ->
  actions = ventilate actions
  actions = values actions
  actions

module.exports.ventilate = ventilate = (action) ->
  if Array.isArray action
    return action.map (action) -> ventilate action
  new_action =
    metadata: action.metadata or {}
    options: action.options or {}
    hooks: action.hooks or {}
  for property, value of action
    if property is 'metadata'
      continue # Already merged before
    else if property is 'options'
      continue # Already merged before
    else if property is 'hooks'
      continue # Already merged before
    else if property in properties_root
      new_action[property] = value
    else if property in properties_metadata
      new_action.metadata[property] = value
    else if /^on_/.test property
      new_action.hooks[property] = value
    else
      new_action.options[property] = value
  new_action

module.exports.values = values = (action) ->
  if Array.isArray action
    return action.map (action) -> values action
  for property, value of properties.metadata
    action.metadata[property] ?= value
  action

module.exports.properties = properties =
  context: undefined
  handler: undefined
  hooks: {}
  metadata:
    # address: null
    # after: null
    argument: null
    # attempt: -1
    # before: null
    # cascade: {}
    debug: false
    deprecate: false
    # depth: 0
    # disabled: false
    # get: false
    header: []
    log: null
    namespace: []
    once: false
    # relax: false
    # retry: 0
    schema: null
    shy: false
    # sleep: 3000
    status: true
    tolerant: false
  parent: null
  registry: null
  options: {}
  plugins: undefined
  scheduler: undefined
  state:
    namespace: []
  run: undefined

properties_root = Object.keys properties
properties_metadata = Object.keys properties.metadata
