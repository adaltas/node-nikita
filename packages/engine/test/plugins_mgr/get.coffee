
plugins = require '../../src/plugins'

describe 'session.plugins.get', ->

  it 'root level', ->
    plugs = plugins()
    plugs.register hooks: 'my:hook': -> 1
    plugs.register hooks: 'my:hook': -> 2
    plugs.get event: 'my:hook'
    .map((hook) -> hook.handler.call()).should.eql [1, 2]

  it 'with parent', ->
    parent = plugins()
    parent.register hooks: 'my:hook': -> 3
    child = plugins parent: parent
    child.register hooks: 'my:hook': -> 1
    child.register hooks: 'my:hook': -> 2
    child.get event: 'my:hook'
    .map((hook) -> hook.handler.call()).should.eql [1, 2, 3]

  it 'throw error if plugin exists by no hook is matching', ->
    (->
      plugs = plugins()
      plugs.register name: 'module/after'
      plugs.register
        hooks: 'my:hook':
          after: 'module/after'
          handler: (->)
      plugs.get event: 'my:hook'
    ).should.throw [
      'PLUGINS_HOOK_AFTER_INVALID:'
      'the hook "my:hook"'
      'references an after dependency'
      'in plugin "module/after" which does not exists'
    ].join ' '

  it 'throw error if plugin does not exists', ->
    (->
      plugs = plugins()
      plugs.register
        hooks: 'my:hook':
          before: 'module/before'
          handler: (->)
      plugs.get event: 'my:hook'
    ).should.throw [
      'PLUGINS_HOOK_BEFORE_INVALID:'
      'the hook "my:hook"'
      'references a before dependency'
      'in plugin "module/before" which does not exists'
    ].join ' '

  it 'after and before as function', ->
    plugs = plugins()
    plugs.register module: 'module/after', hooks: 'my:hook': (->)
    plugs.register module: 'module/before', hooks: 'my:hook': (->)
    plugs.register
      module: 'module/origin'
      hooks: 'my:hook':
        after: 'module/after', before: 'module/before'
        handler: (->)
    plugs.get event: 'my:hook'
    .map (hook) -> hook.module
    .should.eql [
      'module/after', 'module/origin', 'module/before'
    ]
