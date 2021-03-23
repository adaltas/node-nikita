
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.plugins.on_normalize', ->
  return unless tags.api

  it 'call action from global registry', ->
    nikita.call
      $hooks: on_normalize: ({config}, handler) ->
        ->
          action = handler.call null, ...arguments
          action.config.a_key = 'new value'
          action
      a_key: 'a value'
    , ({config}) ->
      config.a_key.should.eql 'new value'

  it 'catch errors', ->
    nikita.call
      $hooks: on_normalize: ({config}, handler) ->
        throw Error 'catchme'
    .should.be.rejectedWith 'catchme'
        
