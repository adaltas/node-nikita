
registry = require './registry'

module.exports =
  '': handler: (->)
  'call':
    '': {}
  'registry':
    'get': raw: true, handler: ({parent, options: [namespace]}) ->
      parent.registry.get namespace
    'register': raw: true, handler: ({parent, options: [namespace, action]}) ->
      parent.registry.register namespace, action
    'registered': raw: true, handler: ({parent, options: [namespace]}) ->
      parent.registry.registered namespace
    'unregister': raw: true, handler: ({parent, options: [namespace]}) ->
      parent.registry.unregister namespace
  'ssh':
    '': '@nikitajs/engine/src/actions/ssh'
    'open': '@nikitajs/engine/src/actions/ssh/open'
(->
  await registry.register module.exports
)()
