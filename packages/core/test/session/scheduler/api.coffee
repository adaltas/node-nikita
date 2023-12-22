
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'session.scheduler.api', ->
  return unless test.tags.api

  describe 'scheduler:args', ->

    it 'function', ->
      nikita ->
        (await @call ->
          new Promise (resolve) -> resolve 1
        ).should.eql 1

    it 'array', ->
      (await nikita.call [
        -> new Promise (resolve) -> resolve 1
        -> new Promise (resolve) -> resolve 2
      ])
      .should.eql [1, 2]

    it 'array', ->
      (await nikita.call [])
      .should.eql []
