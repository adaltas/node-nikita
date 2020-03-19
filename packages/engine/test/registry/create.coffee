
registry = require '../../src/registry'

describe 'registry.create', ->

  it 'static', ->
    registry.create.should.be.a.Function()

  it 'instance', ->
    registry.create().create.should.be.a.Function()

  it 'instance inherit parent chain', ->
    chain = 'hello'
    registry
    .create(chain: chain)
    .create().register 'key': (->)
    .should.eql chain
