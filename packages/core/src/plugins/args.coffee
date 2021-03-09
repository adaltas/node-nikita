

###
The `args` plugin place the original argument into the action "args" property.

###
utils = require '../utils'

module.exports =
  name: '@nikitajs/core/src/plugins/args'
  hooks:
    'nikita:arguments':
      handler: ({args, child}, handler) ->
        # return handler is args.length is 0 # nikita is called without any args, eg `nikita.call(...)`
        # Erase all arguments to re-inject them later
        # return null if args.length is 1 and args[0]?.args
        if child?.metadata?.raw_input #or child?.metadata?.raw
          arguments[0].args = [{}]
        ->
          actions = handler.apply null, arguments
          # If raw_input is activated, just pass arguments as is
          # Always one action since arguments are erased
          if child?.metadata?.raw_input
            actions.args = args
            actions.metadata.raw_input = true
            return actions
          # Otherwise, compute args and pass them to the returned actions
          args = utils.array.multiply ...args
          if Array.isArray actions
            actions.map (action,i) ->
              action.args = args[i]
              action
          else if actions
            actions.args = args[0]
            actions
    'nikita:normalize': (action, handler) ->
      ->
        # Prevent arguments to move into config by normalize
        args = action.args
        delete action.args
        action = await handler.apply null, arguments
        action.args = args
        action
