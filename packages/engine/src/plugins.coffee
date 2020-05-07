
{is_object_literal, is_object, merge} = require 'mixme'
toposort = require 'toposort'
error = require './utils/error'
array = require './utils/array'

normalize_hook = (event, hook) ->
  unless Array.isArray hook
    hook = [hook]
  hook.map (hook) ->
    if typeof hook is 'function'
      hook = handler: hook
    else if not is_object hook or typeof hook isnt 'function'
      throw error 'PLUGINS_HOOK_INVALID_HANDLER', [
        'no hook handler function could be found,'
        'a hook must be defined as a function'
        'or as an object with an handler property'
        "got #{JSON.stringify hook}."
      ]
    hook.event = event
    # hook.after ?= []
    hook.after = [hook.after] if typeof hook.after is 'string'
    # hook.before ?= []
    hook.before = [hook.before] if typeof hook.before is 'string'
    hook

module.exports = ({action, chain, parent, plugins = []} = {}) ->
  # Internal plugin store
  store = []
  # Public API definition
  obj =
    # Register new plugins
    register: (plugin) ->
      throw error('PLUGINS_REGISTER_INVALID_ARGUMENT', [
        'a plugin must consist of keys representing the hook module name'
        'associated with function implementing the hook,'
        "got #{plugin}."
      ]) unless is_object_literal plugin
      plugin.hooks ?= {}
      for event, hook of plugin.hooks
        plugin.hooks[event] = normalize_hook event, hook
      store.push plugin
      chain or @
    get: ({event, hooks = [], sort = true}) ->
      hooks = [
        ...normalize_hook event, hooks
        ...array.flatten( for plugin in store
          continue unless plugin.hooks[event]
          for hook in plugin.hooks[event]
            merge
              module: plugin.module
            , hook
        )
        ...if parent
        then parent.get event: event, sort: false
        else []
      ]
      return hooks unless sort
      # Topological sort
      index = {}
      index[hook.module] = hook for hook in hooks
      edges_after = for hook in hooks
        continue unless hook.after
        for after in hook.after
          # This check assume the plugin has the same hooks which is not always the case
          unless index[after]
            throw errors.PLUGINS_HOOK_AFTER_INVALID
              event: event, module: module, after: after
          [index[after], hook]
      edges_before = for hook in hooks
        continue unless hook.before
        for before in hook.before
          unless index[before]
            throw errors.PLUGINS_HOOK_BEFORE_INVALID
              event: event, module: module, after: after
          [hook, index[before]]
      edges = [...edges_after, ...edges_before]
      edges = array.flatten edges, 0
      toposort.array hooks, edges
    # Call a hook against each registered plugin matching the hook event
    hook: ({args = [], handler, hooks = [], event, silent})->
      if arguments.length isnt 1
        throw error 'PLUGINS_INVALID_ARGUMENTS_NUMBER', [
          'function hook expect 1 object argument,'
          "got #{arguments.length} arguments."
        ]
      else unless is_object_literal arguments[0]
        throw error 'PLUGINS_INVALID_ARGUMENT_PROPERTIES', [
          'function hook expect argument to be a literal object'
          'with the event, args, hooks and handler properties,'
          "got #{JSON.stringify arguments[0]} arguments."
        ]
      else unless typeof event is 'string'
        throw error 'PLUGINS_INVALID_ARGUMENT_EVENT', [
          'function hook expect a event properties in its first argument,'
          "got #{JSON.stringify arguments[0]} argument."
        ]
      # Retrieve the event hooks
      hooks = this.get hooks: hooks, event: event
      # Call the hooks
      for hook in hooks
        switch hook.handler.length
          when 1 then await hook.handler.call @, args
          when 2 then handler = await hook.handler.call @, args, handler
      # Call the final handler
      return handler if silent
      handler.call @, args if handler
  # Register initial plugins
  for plugin in plugins
    obj.register plugin action
  # return the object
  obj

errors =
  PLUGINS_HOOK_AFTER_INVALID: ({event, module, after}) ->
    throw error 'PLUGINS_HOOK_AFTER_INVALID', [
      "the hook #{JSON.stringify event}"
      "in plugin #{JSON.stringify module}" if module
      'references an after dependency'
      "in plugin #{JSON.stringify after} which does not exists"
    ]
  PLUGINS_HOOK_BEFORE_INVALID: ({event, module, after}) ->
    throw error 'PLUGINS_HOOK_BEFORE_INVALID', [
      "the hook #{JSON.stringify event}"
      "in plugin #{JSON.stringify module}" if module
      'references a before dependency'
      "in plugin #{JSON.stringify before} which does not exists"
    ]
