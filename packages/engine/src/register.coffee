
registry = require './registry'

module.exports =
  '': handler: (->)
  'call':
    '': {}
  'registry':
    'get': handler: ({parent, options}) ->
      parent.registry.get options.namespace
    'register': handler: ({parent, options}) ->
      parent.registry.register options.namespace, options.action
    'registered': handler: ({parent, options}) ->
      parent.registry.registered options.namespace
    'unregister': handler: ({parent, options}) ->
      parent.registry.unregister options.namespace
(->
  await registry.register module.exports
)()
