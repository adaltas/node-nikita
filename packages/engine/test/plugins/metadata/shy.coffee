
nikita = require '../../../src'
{tags} = require '../../test'

return unless tags.api

describe 'plugins.metadata.shy', ->

  it 'dont alter status', ->
    {status} = await nikita ->
      @call shy: true, -> true
      @call -> false
      null
    status.should.eql false

  it 'doesnt apply to output', ->
    {status} = await nikita ->
      {status} = await @call shy: true, -> true
      status.should.eql true
      null
    status.should.eql false

  it 'output from array', ->
    count = 0
    nikita ->
      {status} = await @call ->
        [act1, act2] = await @call [
          shy: true
          handler: -> true
        ,
          shy: false
          handler: -> false
        ]
        act1.status.should.be.true()
        act2.status.should.be.false()
        null
      status.should.be.false()
      {status} = await @call ->
        [act1, act2] = await @call [
          shy: false
          handler: -> true
        ,
          shy: true
          handler: -> false
        ]
        act1.status.should.be.true()
        act2.status.should.be.false()
        null
      status.should.be.true()
