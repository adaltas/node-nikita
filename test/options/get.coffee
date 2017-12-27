
nikita = require '../../src'

describe 'options "domain"', ->

  it 'synchronous call', ->
    n = nikita
    result = n.call
      get: true
      handler: -> 'get me'
    result.should.eql 'get me'

  it 'synchronous registered action', ->
    n = nikita
    n.registry.register ['an', 'action'], 
      get: true
      handler: -> 'get me'
    result = n.an.action()
    result.should.eql 'get me'
