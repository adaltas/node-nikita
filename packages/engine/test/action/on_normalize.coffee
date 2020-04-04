
nikita = require '../../src'

describe 'action `on_normalize`', ->

  it 'call action from global registry', ->
    nikita.call
      on_normalize: ({options}, handler) ->
        ->
          action = handler.call null, ...arguments
          action.options.a_key = 'new value'
          action
      a_key: 'a value'
      handler: ({options}) ->
        options.a_key.should.eql 'new value'
        
