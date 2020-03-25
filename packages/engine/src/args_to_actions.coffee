
{is_object, merge, mutate} = require 'mixme'
array = require './misc/array'

module.exports = (args) ->
  actions = multiply args
  actions = reconstituate actions
  actions = ventilate actions
  actions = values actions
  actions

module.exports.build = (args) ->
  actions = multiply args
  actions = reconstituate actions
  actions

module.exports.normalize = (actions) ->
  actions = ventilate actions
  actions = values actions
  actions
  
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

module.exports.reconstituate = reconstituate = (actions) ->
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

module.exports.ventilate = ventilate = (action) ->
  if Array.isArray action
    return action.map (action) -> ventilate action
  new_action =
    metadata: action.metadata or {}
    options: action.options or {}
  for property, value of action
    if property is 'metadata'
      continue # Already merged before
    else if property is 'options'
      continue # Already merged before
    else if property in properties_root
      new_action[property] = value
    else if property in properties_metadata
      new_action.metadata[property] = value
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
  handler: null
  metadata:
    # address: null
    namespace: []
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
  parent: null
  registry: null
  options: {}
  plugins: undefined
  scheduler: undefined
  state:
    namespace: []

properties_root = Object.keys properties
properties_metadata = Object.keys properties.metadata
