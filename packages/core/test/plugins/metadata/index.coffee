
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.metadata.index', ->
  return unless test.tags.api

  it 'start at 0', ->
    nikita
    .call ({metadata}) ->
      metadata.index.should.eql 0
      @call ({metadata}) ->
        metadata.index.should.eql 0

  it 'is incremented', ->
    nikita
    .call -> true
    .call ({metadata}) ->
      metadata.index.should.eql 1
