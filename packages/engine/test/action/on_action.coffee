
nikita = require '../../src'

describe 'action `on_action`', ->

  it 'call action from global registry', ->
    nikita.call
      on_action: ({options}) ->
        options.a_key = 'new value'
      a_key: 'a value'
      handler: ({options}) ->
        options.a_key.should.eql 'new value'
        
