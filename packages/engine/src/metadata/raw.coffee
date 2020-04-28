
module.exports = ->
  module: '@nikitajs/engine/src/metadata/raw'
  hooks:
    'nikita:session:arguments': ({args, child, namespace, parent}, handler) ->
      return handler unless child.metadata.raw_input
      # Erase all arguments to re-inject them later
      arguments[0].args = []
      (context) ->
        actions = handler.call null, context
        # Re-inject arguments
        if Array.isArray actions
          actions.map (action,i) ->
            action.args = args
            action
        else
          actions.args = args
          actions
    'nikita:registry:normalize': (action) ->
      action.metadata ?= {}
      for property in ['raw', 'raw_input', 'raw_output']
        if action.hasOwnProperty property
          action.metadata[property] = action[property]
          delete action[property]
      action.metadata.raw ?= false
      action.metadata.raw_input ?= action.metadata.raw
      action.metadata.raw_output ?= action.metadata.raw
    'nikita:session:normalize': (action, handler) ->
      # Move property from action to metadata
      for property in ['raw', 'raw_input', 'raw_output']
        if action.hasOwnProperty property
          action.metadata[property] = action[property]
          delete action[property]
      return handler unless action.args
      ->
        args = action.args
        delete action.args
        action = handler.apply null, arguments
        action.args = args
        action
    'nikita:session:action': (action) ->
      action.metadata.raw ?= false
      action.metadata.raw_input ?= action.metadata.raw
      action.metadata.raw_output ?= action.metadata.raw
