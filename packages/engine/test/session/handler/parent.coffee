
nikita = require '../../../src'

describe 'session.handler.parent', ->
    
  it 'parent is interpreted as a config', ->
    nikita.call
      parent: true
    , ({config}) ->
      config.parent.should.be.true()
