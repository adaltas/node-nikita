

###
The `args` plugin place the original argument into the action "args" property.

###
utils = require '../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/args'
  hooks:
    'nikita:session:arguments':
      handler: ({args, child}, handler) ->
        # Erase all arguments to re-inject them later
        if child.metadata.raw_input
          arguments[0].args = []
        ->
          actions = await handler.apply null, arguments
          # If raw_input is activated, just pass arguments as is
          # Always one action since arguments are erased
          if child.metadata.raw_input
            actions.args = args
            actions.metadata.raw_input = true
            return actions
          # Otherwise, compute args and pass them to the returned actions
          args = utils.array.multiply ...args
          if Array.isArray actions
            actions.map (action,i) ->
              action.args = args[i]
              action
          else
            actions.args = args[0]
            actions
    'nikita:session:normalize': (action, handler) ->
      ->
        # Prevent arguments to move into config by normalize
        args = action.args
        delete action.args
        action = await handler.apply null, arguments
        action.args = args
        action
