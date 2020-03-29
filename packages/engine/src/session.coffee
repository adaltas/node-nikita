
{merge} = require 'mixme'
registry = require './registry'
schedule = require './schedule'
plugins = require './plugins'
conditions = require './plugins/conditions'
schema = require './plugins/schema'
args_to_actions = require './args_to_actions'

run = (parent, ...args) ->
  # Convert arguments to array
  # args = [].slice.call arguments
  # Are we scheduling multiple actions
  args_is_array = args.some (arg) -> Array.isArray arg
  actions = args_to_actions.build [
    metadata:
      # namespace: []
      depth: if parent then parent.metadata.depth + 1 else 0
    state:
      namespace: []
    parent: parent
    ...args
  ]
  proms = actions.map (action) ->
    session action
  if args_is_array then Promise.all(proms) else proms[0]

session = (action={}) ->
  # Catch calls to new actions
  on_call = () ->
    # Extract action namespace and reset the state
    namespace = action.state.namespace.slice()
    action.state.namespace = []
    args = arguments
    prom = action.scheduler.add ->
      # Validate the namespace
      unless action.registry.registered namespace
        return Promise.reject Error "No action named #{JSON.stringify namespace.join '.'}"
      action.run ...args, metadata: namespace: namespace
    new Proxy prom, get: on_get
  # Building the namespace before calling an action
  on_get = (target, name) ->
    if target[name]? and not action.registry.get(name)
      if typeof target[name] is 'function'
        return target[name].bind target
      else
        return target[name]
    if action.state.namespace.length is 0
      switch name
        # when 'registry' then return action.registry
        when 'plugins' then return action.plugins
    action.state.namespace.push name
    new Proxy on_call, get: on_get
  # Initialize the registry to manage action registration
  action.registry = registry.create
    # chain: new Proxy on_call, get: on_get
    parent: if action.parent then action.parent.registry else registry
    on_register: (name, act) ->
      await action.plugins.hook
        name: 'nikita:registry:action:register'
        args:
          name: name
          action: act
  # Initialize the plugins manager
  action.plugins = plugins
    plugins: action.plugins
    chain: new Proxy on_call, get: on_get
    parent: if action.parent then action.parent.plugins else undefined
    action: action
  # Local scheduler
  action.scheduler = schedule()
  setImmediate ->
    action.scheduler.pump()
  # Execute the action
  result = new Promise (resolve, reject) ->
    # Register run helper
    action.run = ->
      run action, ...arguments
    # Make sure the promise is resolved after the scheduler and its children
    on_end = new Promise (resolve, reject) ->
      action.scheduler.on_end ->
        resolve()
    # Hook attented to modify the current action being created
    action = await action.plugins.hook
      name: 'nikita:session:normalize:user'
      args:
        action: action
      handler: ({action}) ->
        action = args_to_actions.normalize action
        action
    if action.metadata.namespace
      action_from_registry = action.registry.get action.metadata.namespace
      action = merge action_from_registry, action
    context = new Proxy on_call, get: on_get
    action.context = context
    # Hook attented to alter the execution of an action handler
    try
      output = action.plugins.hook
        name: 'nikita:session:handler:call',
        args:
          context: context
          action: action
        handler: ({context, action}) ->
          action.handler.call context, action
      unless output and output.then
        output = new Promise (resolve, reject) ->
          resolve output
      Promise.all([output, on_end])
      .then (values) ->
        resolve values.shift()
      .catch reject
    catch err
      reject err
  # Returning a proxified promise:
  # - news action can be registered to it as long as the promised has not fulfilled
  # - resolve when all registered actions are fulfilled
  # - resolved with the result of handler
  new Proxy result, get: on_get

module.exports = ->
  run null, plugins: [
    conditions
    schema
  ], ...arguments
