

module.exports =
  name: '@nikitajs/core/src/plugins/history'
  hooks:
    'nikita:normalize': (action, handler) ->
      ->
        action = await handler.call null, ...arguments
        action.children = []
        action.siblings ?= []
        action.siblings = action.parent.children if action.parent
        action.sibling = action.siblings.slice(-1)[0] if action.parent
        action
    'nikita:result': ({action, error, output}) ->
      return unless action.parent
      action.parent.children.push
        children: action.children
        metadata: action.metadata
        config: action.config
        error: error
        output: output
