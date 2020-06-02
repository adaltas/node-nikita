
nikita = require '../../../src'

describe 'session.handler.config', ->
    
  it 'ensure it is not polluted', ->
    nikita.call ({config}) ->
      config.should.eql {}
