
nikita = require '../../../src'
{tags} = require '../../test'

return unless tags.api

describe 'metadata.shy', ->

  it 'dont alter status', ->
    nikita ->
      @call shy: true, -> true
      @call -> false
      null
    .should.be.resolvedWith status: false

  it 'doesnt apply to output', ->
    nikita ->
      @call shy: true, -> true
      .should.be.resolvedWith status: true
      null
    .should.be.resolvedWith status: false

  it 'output from array', ->
    count = 0
    nikita ->
      @call ->
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
      .should.be.resolvedWith status: false
      @call ->
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
      .should.be.resolvedWith status: true
