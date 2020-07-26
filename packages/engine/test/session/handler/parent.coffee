
nikita = require '../../../src'

describe 'session.handler.parent', ->
    
  it 'parent config dont conflict', ->
    nikita.call
      parent: true
    , ({config}) ->
      config.parent.should.be.true()
