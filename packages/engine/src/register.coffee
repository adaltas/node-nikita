
registry = require './registry'

module.exports =
  '': handler: (->)
  'call':
    '': {}
  'registry':
    'get': handler: ({parent, options}) ->
      parent.registry.get options.namespace
    'register': handler: ({parent, options}) ->
      parent.registry.register options.action.namespace, options.action
    'registered': handler: ({parent, options}) ->
      parent.registry.registered options.namespace
    'unregister': handler: ({parent, options}) ->
      parent.registry.unregister options.namespace
  'ssh':
    '': '@nikitajs/engine/src/actions/ssh'
    'open': '@nikitajs/engine/src/actions/ssh/open'
(->
  await registry.register module.exports
)()
