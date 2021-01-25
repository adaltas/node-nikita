

module.exports =
  module: '@nikitajs/engine/src/plugins/history'
  hooks:
    'nikita:session:normalize': (action, handler) ->
      ->
        action = await handler.call null, ...arguments
        action.children = []
        action.siblings = action.parent.children if action.parent
        action.sibling = action.siblings.slice(-1)[0] if action.parent
        action
    'nikita:session:result': ({action, error, output}) ->
      return unless action.parent
      action.parent.children.push
        children: action.children
        metadata: action.metadata
        config: action.config
        error: error
        output: output
