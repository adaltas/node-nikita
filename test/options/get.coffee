
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

  it 'clone options', ->
    my_options = a_key: 'a value'
    n = nikita
    n.call
      get: true
    , my_options
    , (options) ->
      options['a_key'] = 'should not be visible'
    n.next ->
      my_options['a_key'].should.eql 'a value'
    n.promise()
