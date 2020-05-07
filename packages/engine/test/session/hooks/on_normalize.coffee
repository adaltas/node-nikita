
nikita = require '../../../src'

describe 'session.hooks.on_normalize', ->

  it 'call action from global registry', ->
    nikita.call
      on_normalize: ({config}, handler) ->
        ->
          action = handler.call null, ...arguments
          action.config.a_key = 'new value'
          action
      a_key: 'a value'
      handler: ({config}) ->
        config.a_key.should.eql 'new value'
        
