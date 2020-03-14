
{merge} = require 'mixme'
registry = require './registry'

# registry = ({chain, parent}) ->
#   store:
#     '': handler: ({metadata}) ->
#       key: "root value, depth #{metadata.depth}"
#     action:
#       '': handler: ({metadata}) ->
#         @an.action()
#         key: "action value, depth #{metadata.depth}"
#     an:
#       action:
#         '': handler: ({metadata}) ->
#           key: "an.action value, depth #{metadata.depth}"
#     call:
#       '': {}
#   get: (namespace) ->
#     action = registry.store
#     for key in namespace
#       action = action[key]
#     action and action['']
#   exists: (namespace, leaf) ->
#     action = registry.store
#     for key in namespace
#       action = action[key]
#     !! if leaf
#     then action and action['']
#     else action

registry.register
  '': handler: ({metadata}) ->
    key: "root value, depth #{metadata.depth}"
  'action':
    '': handler: ({metadata}) ->
      @an.action()
      key: "action value, depth #{metadata.depth}"
  'an':
    'action':
      '': handler: ({metadata}) ->
        key: "an.action value, depth #{metadata.depth}"
  'call':
    '': {}

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
  scheduler = schedule(action.metadata.namespace.join '.')
  setImmediate ->
    scheduler.pump()
  on_call = () ->
    handler = arguments[0] if typeof arguments[0] is 'function'
    # Extract action namespace and reset the state
    namespace = action.state.namespace.slice()
    action.state.namespace = []
    unless registry.registered namespace, partial: false, parent: true
      err = Error "No action named #{namespace.join '.'}"
      throw err
    prom = new Promise (resolve, reject) ->
      sch = ->
        session
          metadata:
            depth: action.metadata.depth + 1
            namespace: namespace
          registry: action.registry
          handler: handler
        .then resolve, reject
      sch.id = namespace.join '.'
      scheduler.add sch
    new Proxy prom, get: on_get
  on_get = (target, name) ->
    return target[name].bind target if target[name]?
    if action.state.namespace is [] and name is 'registry'
      return action.registry
    action.state.namespace.push name
    unless registry.registered action.state.namespace, partial: true, parent: true
      action.state.namespace = []
      return undefined
    new Proxy on_call, get: on_get
  # Execute the action
  result = new Promise (resolve, reject) ->
    if action.metadata.namespace
      action_from_registry = registry.get action.metadata.namespace
      action = merge action_from_registry, action
    context = new Proxy on_call, get: on_get
    output = action.handler.call context, action
    unless output.then
      output = new Promise (resolve, reject) ->
        resolve output
    on_end = new Promise (resolve, reject) ->
      scheduler.on_end ->
        resolve()
    Promise.all([output, on_end])
    .catch reject
    .then (values) ->
      resolve values.shift()
  proxy = new Proxy result, get: on_get
  action.registry ?= registry.create
    chain: proxy
    parent: registry
  proxy

module.exports = session
