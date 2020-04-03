
plugins = require '../../src/plugins'

describe 'plugins', ->

  it 'hook handler alter args with 1 argument', ->
    plugs = plugins()
    plugs.register 'my:hook': (test) ->
      test.a_key = 'a value'
    test = {}
    await plugs.hook
      name: 'my:hook'
      args: test
      handler: (->)
    test.a_key.should.eql 'a value'

  it 'hook handler alter args with 2 arguments', ->
    plugs = plugins()
    plugs.register 'my:hook': (test, handler) ->
      test.a_key = 'a value'
      handler
    test = {}
    await plugs.hook
      name: 'my:hook'
      args: test
      handler: (->)
    test.a_key.should.eql 'a value'
