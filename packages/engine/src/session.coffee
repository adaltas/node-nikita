
{merge} = require 'mixme'
registry = require './registry'

schedule = ->
  stack = []
  running = false
  events =
    end: []
  on_end: (fn) ->
    events.end.push fn
    @
  pump: ->
    return if running
    running = true
    if fn = @next()
      fn.call()
      .catch (err) ->
        running = false
        throw err
      .then =>
        running = false
        setImmediate =>
          @pump()
    else
      for fn in events.end
        fn.call()
  next: ->
    stack.shift()
  add: (fn) ->
    stack.push fn
    # Pump execution
    setImmediate =>
      @pump()
    fn

session = (action={}) ->
  if typeof action is 'function'
    action = handler: action
  action = merge
    metadata:
      namespace: []
    state:
      namespace: []
  , action
  action.metadata.depth ?= 0
  # Local scheduler
  scheduler = schedule(action.metadata.namespace.join '.')
  setImmediate ->
    scheduler.pump()
  on_call = () ->
    handler = arguments[0] if typeof arguments[0] is 'function'
    # Extract action namespace and reset the state
    namespace = action.state.namespace.slice()
    action.state.namespace = []
    unless action.registry.registered namespace
      throw Error "No action named #{namespace.join '.'}"
    prom = new Promise (resolve, reject) ->
      sch = ->
        session
          metadata:
            depth: action.metadata.depth + 1
            namespace: namespace
          parent: action
          handler: handler
        .then resolve, reject
      sch.id = namespace.join '.'
      scheduler.add sch
    new Proxy prom, get: on_get
  on_get = (target, name) ->
    return target[name].bind target if target[name]?
    if action.state.namespace.length is 0 and name is 'registry'
      return action.registry
    action.state.namespace.push name
    unless action.registry.registered action.state.namespace, partial: true
      action.state.namespace = []
      return undefined
    new Proxy on_call, get: on_get
  # Execute the action
  result = new Promise (resolve, reject) ->
    # Make sure the promise is resolved after the scheduler and its children
    on_end = new Promise (resolve, reject) ->
      scheduler.on_end ->
        resolve()
    # Wait a bit, action.registry is not yet available
    setImmediate ->
      if action.metadata.namespace
        action_from_registry = action.registry.get action.metadata.namespace
        action = merge action_from_registry, action
      context = new Proxy on_call, get: on_get
      output = action.handler.call context, action
      unless output and output.then
        output = new Promise (resolve, reject) ->
          resolve output
      Promise.all([output, on_end])
      .catch reject
      .then (values) ->
        resolve values.shift()
  proxy = new Proxy result, get: on_get
  # Create the registry and path the proxy reference for chaining
  action.registry ?= registry.create
    chain: proxy
    parent: if action.parent then action.parent.registry else registry
  proxy

module.exports = session
