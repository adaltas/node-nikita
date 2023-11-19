
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'session.scheduler.option.strict', ->
  return unless test.tags.api

  it 'function', ->
    nikita
    .call -> true
    .call -> throw Error 'catchme'
    .call -> true
    .should.be.rejectedWith 'catchme'
