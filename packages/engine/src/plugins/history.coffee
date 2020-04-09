

module.exports = ->
  name: 'history'
  hooks:
    'nikita:session:normalize': (action, handler) ->
      ->
        action = handler.call null, ...arguments
        action.children = []
        action.siblings = action.parent.children if action.parent
        action.sibling = action.siblings.slice(-1)[0] if action.parent
        action
    'nikita:session:result': ({action}, handler) ->
      return handler unless action.parent
      ({action, error, output}) ->
        action.parent.children.push
          children: action.children
          metadata: action.metadata
          config: action.config
          error: error
          output: output
        handler.apply null, arguments
