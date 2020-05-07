
# # Registry
#
# Management facility to register and unregister actions.
#
# ## Register all functions

create = ({chain, on_register, parent, plugins} = {}) ->
  store = {}
  obj =
    chain: chain

# ## Create
#
# Create a new registry.
#
# Options include:
#
# * `chain`
#   Default object to return, used by `register`, `deprecate` and `unregister`.
#   Could be used to provide a chained style API.
# * `on_register`
#   User function called on action registration. Takes two arguments: the action
#   name and the action itself.
# * `parent`
#   Parent registry.

  obj.create = (options={}) ->
    # Inherit options from parent
    options = merge
      chain: obj.chain
      on_register: on_register
      parent: parent
    , options
    # Create the child registry
    create options

# ## load
#
# Load an action from the module name.

  obj.load = (module) ->
    throw Error "Invalid Argument: module must be a string, got #{module.toString()}" unless typeof module is 'string'
    action = if /^@nikitajs\/engine\//.test module
    then require.main.require module
    else require './' + module.substr 21
    if typeof action is 'function'
      action = handler: action
    action.metadata ?= {}
    action.metadata.module = module
    action

# ## Get
#
# Retrieve an action by name.
#
# Options include:
#
# * `flatten`
# * `deprecate`

  obj.get = (namespace, options) ->
    if arguments.length is 1 and is_object arguments[0]
      options = namespace
      namespace = null
    options ?= {}
    options.normalize ?= true
    unless namespace
      # Flatten result
      if options.flatten
        actions = []
        walk = (store, keys) ->
          for k, v of store
            if k is ''
              continue if v.metadata?.deprecate and not options.deprecate
              # flatstore[keys.join '.'] = merge v
              v.action = keys
              actions.push merge v
            else
              walk v, [keys..., k]
        walk store, []
        return actions
      # Tree result
      else
        walk = (store, keys) ->
          res = {}
          for k, v of store
            if k is ''
              continue if v.metadata?.deprecate and not options.deprecate
              res[k] = merge v
            else
              v = walk v, [keys..., k]
              res[k] = v unless Object.values(v).length is 0
          res
        return walk store, []
    namespace = [namespace] if typeof namespace is 'string'
    child_store = store
    for n, i in namespace.concat ['']
      break unless child_store[n]
      # return child_store[n] if child_store[n] and i is namespace.length
      if child_store[n] and i is namespace.length
        action = child_store[n]
        return action unless options.normalize
        return if plugins
          # Hook attented to modify an action returned by the registry
          await plugins.hook
            event: 'nikita:registry:normalize'
            args: action
            handler: (action) ->
              normalize action
        else
          normalize action
      child_store = child_store[n]
    if parent
      action = await parent.get namespace, {...options, normalize: false}
      return null unless action?
      action = if plugins
        action = await plugins.hook
          event: 'nikita:registry:normalize'
          args: action
          handler: (action) ->
            normalize action
      else
        normalize action
      return action
    else null

# ## Register
#
# Register new actions.
#
# With an action path:
#
# ```javascript
# nikita.register('first_action', 'path/to/action')
# nikita.first_action(options);
# ```
#
# With a namespace and an action path:
#
# ```javascript
# nikita.register(['second', 'action'], 'path/to/action')
# nikita.second.action(options);
# ```
#
# With an action object:
#
# ```javascript
# nikita.register('third_action', {
#   relax: true,
#   handler: function(options){ console.info(options.relax) }
# })
# nikita.third_action(options);
# ```
#
# With a namespace and an action object:
#
# ```javascript
# nikita.register(['fourth', 'action'], {
#   relax: true,
#   handler: function(options){ console.info(options.relax) }
# })
# nikita.fourth.action(options);
# ```
#
# Multiple actions:
#
# ```javascript
# nikita.register({
#   'fifth_action': 'path/to/action'
#   'sixth': {
#     '': 'path/to/sixth',
#     'action': : 'path/to/sixth/actkon'
#   }
# })
# nikita
# .fifth_action(options);
# .sixth(options);
# .sixth.action(options);
# ```

  obj.register = (namespace, action) ->
    namespace = [namespace] if typeof namespace is 'string'
    if Array.isArray namespace
      return obj.chain or obj if action is undefined
      if typeof action is 'string'
        action = obj.load action
      else if typeof action is 'function'
        action = handler: action
      child_store = store
      for i in [0...namespace.length]
        property = namespace[i]
        child_store[property] ?= {}
        child_store = child_store[property]
      child_store[''] = action
      if on_register
        await on_register namespace, action
    else
      walk = (namespace, store) ->
        for k, action of store
          if k isnt '' and action and typeof action is 'object' and not Array.isArray(action) and not (action.handler or action.module)
            namespace.push k
            await walk namespace, action
          else
            if typeof action is 'string'
              action = obj.load action
            else if typeof action is 'function'
              action = handler: action
            namespace.push k
            store[k] = if k is '' then action else
              '': action
            if on_register
              await on_register namespace, action
      await walk [], namespace
      mutate store, namespace
    obj.chain or obj

# ## Deprecate
#
# `nikita.deprecate(old_function, [new_function], action)`
#
# Deprecate an old or renamed action. Internally, it leverages
# [Node.js `util.deprecate`](https://nodejs.org/api/util.html#util_util_deprecate_function_string).
#
# For example:
#
# ```javascript
# nikita.deprecate('old_function', 'new_function', -> 'my_function')
# nikita.old_function()
# # Print
# # (node:75923) DeprecationWarning: old_function is deprecated, use new_function
# ```

  obj.deprecate = (old_name, new_name, action) ->
    if arguments.length is 2
      handler = new_name
      new_name = null
    action = obj.load action if typeof action is 'string'
    if typeof handler is 'function'
      action = handler: handler
    action.metadata ?= {}
    action.metadata.deprecate = new_name
    action.metadata.deprecate ?= action.module if typeof action.module is 'string'
    action.metadata.deprecate ?= true
    obj.register old_name, action
    obj.chain or obj

# # Registered
#
# Test if a function is registered or not.
#
# Options:
#
# * `local` (boolean)
#   Search action in the parent registries.
# * `partial` (boolean)
#   Return true if name match a namespace and not a leaf action.

  obj.registered = (name, options = {}) ->
    name = [name] if typeof name is 'string'
    return true if not options.local and parent and parent.registered name, options
    child_store = store
    for n, i in name
      return false if not child_store[n]? or not child_store.propertyIsEnumerable(n)
      return true if options.partial and child_store[n] and i is name.length - 1
      return true if child_store[n][''] and i is name.length - 1
      child_store = child_store[n]
    false

# ## Unregister
#
# Remove an action from registry.

  obj.unregister = (name) ->
    name = [name] if typeof name is 'string'
    child_store = store
    for n, i in name
      delete child_store[n] if i is name.length - 1
      child_store = child_store[n]
      return obj.chain or obj unless child_store
    obj.chain or obj
  
  obj

module.exports = create()

## Dependencies

{is_object, merge, mutate} = require 'mixme'
normalize = require './session/normalize'
