
plugins = require '../../../src/plugins'

describe 'session.plugins.hook', ->

  it 'hook handler alter args with 1 argument', ->
    plugs = plugins()
    plugs.register hooks: 'my:hook': (test) ->
      test.a_key = 'a value'
    test = {}
    await plugs.hook
      event: 'my:hook'
      args: test
      handler: (->)
    test.a_key.should.eql 'a value'

  it 'hook handler alter args', ->
    plugs = plugins()
    plugs.register hooks: 'my:hook': (test, handler) ->
      test.a_key = 'a value'
      handler
    test = {}
    await plugs.hook
      event: 'my:hook'
      args: test
      handler: (->)
    test.a_key.should.eql 'a value'

  it 'hook handler alter args async', ->
    plugs = plugins()
    plugs.register hooks: 'my:hook': (ar, handler) ->
      ar.push 'alter 1'
      await new Promise (resolve) -> setImmediate resolve
      handler
    plugs.register hooks: 'my:hook': (ar, handler) ->
      ar.push 'alter 2'
      await new Promise (resolve) -> setImmediate resolve
      handler
    ar = []
    await plugs.hook
      event: 'my:hook'
      args: ar
      handler: (ar) -> ar.push 'origin'
    ar.should.eql ['alter 1', 'alter 2', 'origin']

  it 'call handler and alter result sync', ->
    plugs = plugins()
    plugs.register hooks: 'my:hook': (test, handler) ->
      ->
        res = handler.apply null, arguments
        res.push 'alter_1'
        res
    plugs.register hooks: 'my:hook': (test, handler) ->
      ->
        res = handler.apply null, arguments
        res.push 'alter_2'
        res
    plugs.hook
      event: 'my:hook'
      args: {}
      handler: (args) ->
        ['origin']
    .should.be.resolvedWith ['origin', 'alter_1', 'alter_2']

  it 'call handler and alter result async', ->
    plugs = plugins()
    plugs.register hooks: 'my:hook': (test, handler) ->
      ->
        res = await handler.apply null, arguments
        res.push 'alter_1'
        await new Promise (resolve) -> setImmediate resolve
        res
    plugs.register hooks: 'my:hook': (test, handler) ->
      ->
        res = await handler.apply null, arguments
        res.push 'alter_2'
        await new Promise (resolve) -> setImmediate resolve
        res
    plugs.hook
      event: 'my:hook'
      args: {}
      handler: (args) ->
        ['origin']
    .should.be.resolvedWith ['origin', 'alter_1', 'alter_2']
