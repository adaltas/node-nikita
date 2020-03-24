
{is_object_literal} = require 'mixme'
error = require './utils/error'

module.exports = ({action, chain, parent, plugins = []} = {}) ->
  # Internal plugin store
  store = []
  # Public API definition
  obj =
    # Register new plugins
    register: (hooks) ->
      throw error('PLUGINS_INVALID_HOOK_REGISTRATION', [
        'hooks must consist of keys representing the hook names'
        'associated with function implementing the hook,'
        "got #{hook}."
      ]) unless is_object_literal hooks
      store.push hooks
      chain or @
    # Call a hook against each registered plugin matching the hook name
    hook: ({args = [], handler, hooks = [], name, silent})->
      if arguments.length isnt 1
        throw error 'PLUGINS_INVALID_ARGUMENTS_NUMBER', [
          'function hook expect 1 object argument,'
          "got #{arguments.length} arguments."
        ]
      else unless is_object_literal arguments[0]
        throw error 'PLUGINS_INVALID_ARGUMENT_PROPERTIES', [
          'function hook expect argument to be a literal object'
          'with the name, args, hooks and handler properties,'
          "got #{arguments[0]} arguments."
        ]
      else unless typeof name is 'string'
        throw error 'PLUGINS_INVALID_ARGUMENT_NAME', [
          'function hook expect a name properties in its first argument,'
          "got #{arguments[0]} argument."
        ]
      hooks = [hooks] if typeof hooks is 'function'
      # Call parent hooks
      if parent then await parent.hook.call parent,
        name: name
        args: args
        hooks: hooks
        handler: handler
        silent: true
      # Call local hooks
      for hook in store
        handler = await hook[name].call @, args, handler if hook[name]
      # Call user provided hooks
      if hooks then for hook in hooks
        handler = await hook.call @, args, handler
      # Call the final handler
      return handler if silent
      handler.call @, args if handler
  # Register initial plugins
  for plugin in plugins
    obj.register plugin action
  # return the object
  obj
