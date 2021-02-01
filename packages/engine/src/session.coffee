
{merge} = require 'mixme'
registry = require './registry'
schedule = require './schedulers/native'
plugandplay = require 'plug-and-play'
contextualize = require './session/contextualize'
normalize = require './session/normalize'
utils = require './utils'

session = (action={}) ->
  action.metadata ?= {}
  action.metadata.namespace ?= []
  action.state ?= {}
  action.state.namespace ?= []
  # Catch calls to new actions
  on_call = (...args) ->
    # Extract action namespace and reset the state
    namespace = action.state.namespace.slice()
    action.state.namespace = []
    # Schedule the action and get the result as a promise
    prom = action.scheduler.push ->
      # Validate the namespace
      child = await action.registry.get namespace
      unless child
        return Promise.reject utils.error 'ACTION_UNREGISTERED_NAMESPACE', [
          'no action is registered under this namespace,'
          "got #{JSON.stringify namespace}."
        ]
      actions = await action.plugins.call
        name: 'nikita:session:arguments'
        args: args: args, child: child, parent: action, namespace: namespace
        handler: ({args, parent, namespace}) ->
          actions = contextualize [...args, metadata: namespace: namespace]
          (if Array.isArray actions then actions else [actions]).map (action) ->
            action.config ?= {}
            action.config.parent = action.parent if action.parent?
            action.parent = parent
          actions
      unless Array.isArray actions
        session actions
      else
        # schl = schedule()
        # Promise.all actions.map (action) ->
        #   schl.push -> session action
        schedule actions.map (action) -> -> session action
    new Proxy prom, get: on_get
  # Building the namespace before calling an action
  on_get = (target, name) ->
    if target[name]? and not action.registry.registered name
      if typeof target[name] is 'function'
        return target[name].bind target
      else
        return target[name]
    if action.state.namespace.length is 0
      switch name
        when 'plugins' then return action.plugins
    action.state.namespace.push name
    new Proxy on_call, get: on_get
  # Initialize the plugins manager
  action.plugins = plugandplay
    plugins: action.plugins
    chain: new Proxy on_call, get: on_get
    parent: if action.parent then action.parent.plugins else undefined
  # Initialize the registry to manage action registration
  action.registry = registry.create
    plugins: action.plugins
    parent: if action.parent then action.parent.registry else registry
    on_register: (name, act) ->
      await action.plugins.call
        name: 'nikita:session:register'
        args: name: name, action: act
  # Register run helper
  action.run = ->
    run parent: action, ...arguments
  # Local scheduler to execute children and be notified on finish
  action.scheduler = schedule()
  # Expose the action context
  action.config.context = action.context if action.context
  action.context = new Proxy on_call, get: on_get
  # Execute the action
  result = new Promise (resolve, reject) ->
    # Hook intented to modify the current action being created
    action = await action.plugins.call
      name: 'nikita:session:normalize'
      args: action
      hooks: action.hooks?.on_normalize or action.on_normalize
      handler: normalize
    # Load action from registry
    if action.metadata.namespace
      action_from_registry = await action.registry.get action.metadata.namespace
      # Merge the registry action with the user action properties
      for k, v of action_from_registry
        action[k] = merge action_from_registry[k], action[k]
    # Hook attended to alter the execution of an action handler
    output = action.plugins.call
      name: 'nikita:session:action'
      args: action
      hooks: action.hooks.on_action
      handler: (action) ->
        # Execution of an action handler
        action.handler.call action.context, action
    # Ensure child actions are executed
    pump = -> action.scheduler.pump()
    output.then pump, pump
    # Make sure the promise is resolved after the scheduler and its children
    Promise.all [output, action.scheduler]
    .then (values) ->
      on_result undefined, values.shift()
    , (err) ->
      on_result err
    # Hook to catch error and format output once all children are executed
    on_result = (error, output) ->
      action.plugins.call
        name: 'nikita:session:result'
        args: action: action, error: error, output: output
        hooks: action.hooks.on_result
        handler: ({action, error, output}) ->
          if error then throw error else output
      .then resolve, reject
  result.then (output) ->
    return unless action.parent is undefined
    action.plugins.call
      name: 'nikita:session:resolved'
      args: action: action, output: output
  , (err) ->
    return unless action.parent is undefined
    action.plugins.call
      name: 'nikita:session:rejected'
      args: action: action, error: err
  # Returning a proxified promise:
  # - news action can be registered to it as long as the promised has not fulfilled
  # - resolve when all registered actions are fulfilled
  # - resolved with the result of handler
  new Proxy result, get: on_get

module.exports = run = (...args) ->
  actions = contextualize args
  # Are we scheduling one or multiple actions
  if Array.isArray actions
  then Promise.all actions.map (action) -> session action
  else session actions
