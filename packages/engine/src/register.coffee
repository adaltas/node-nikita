
registry = require './registry'

registry.register module.exports =
  '': handler: (->)
  'action':
    '': handler: ({metadata}) ->
      @an.action()
      key: "action value, depth #{metadata.depth}"
  'an':
    'action':
      '': handler: ({metadata}) ->
        key: "an.action value, depth #{metadata.depth}"
  'call':
    '': {}
