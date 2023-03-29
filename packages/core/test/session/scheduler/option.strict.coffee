
{tags} = require '../../test'
nikita = require '../../../lib'

describe 'session.scheduler.option.strict', ->
  return unless tags.api

  it 'function', ->
    nikita
    .call -> true
    .call -> throw Error 'catchme'
    .call -> true
    .should.be.rejectedWith 'catchme'
