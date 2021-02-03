
nikita = require '../../../src'
{tags} = require '../../test'

describe 'plugins.metadata.shy', ->
  return unless tags.api

  it 'dont alter status', ->
    {status} = await nikita ->
      @call metadata: shy: true, -> true
      @call -> false
      null
    status.should.eql false

  it 'doesnt apply to output', ->
    {status} = await nikita ->
      {status} = await @call metadata: shy: true, -> true
      status.should.eql true
      null
    status.should.eql false

  it 'output from array', ->
    nikita ->
      {status} = await @call ->
        [act1, act2] = await @call [
          metadata: shy: true
          handler: -> true
        ,
          metadata: shy: false
          handler: -> false
        ]
        act1.status.should.be.true()
        act2.status.should.be.false()
        null
      status.should.be.false()
  
  it 'false disreregard a status true', ->
    nikita ->
      {status} = await @call ->
        [act1, act2] = await @call [
          metadata: shy: false
          handler: -> true
        ,
          metadata: shy: true
          handler: -> false
        ]
        act1.status.should.be.true()
        act2.status.should.be.false()
        null
      status.should.be.true()
