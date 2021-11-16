
{tags} = require '../../test'
nikita = require '../../../src'

describe 'session.scheduler.option.strict', ->
  return unless tags.api

  it 'function', ->
    nikita $scheduler: strict: true
    .call -> true
    .call -> throw Error 'catchme'
    .call -> true
    .should.be.rejectedWith 'catchme'
