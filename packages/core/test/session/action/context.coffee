
nikita = require '../../../src'

describe 'session.handler.context', ->
  
  it 'context config dont conflict', ->
    nikita.call
      context: true
    , ({config}) ->
      config.context.should.be.true()
