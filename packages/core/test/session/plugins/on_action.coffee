
nikita = require '../../../src'

describe 'session.plugins.on_action', ->

  it 'call action from global registry', ->
    nikita.call
      on_action: ({config}) ->
        config.a_key = 'new value'
      a_key: 'a value'
      handler: ({config}) ->
        config.a_key.should.eql 'new value'
        
