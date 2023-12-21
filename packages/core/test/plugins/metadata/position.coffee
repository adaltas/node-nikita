
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.metadata.position', ->
  return unless test.tags.api

  it 'start at 0', ->
    nikita ({metadata}) ->
      metadata.position.should.eql [0]

  it 'are concatenated', ->
    nikita
    .call ({metadata}) ->
      metadata.position.should.eql [0, 0]

  it 'are incremented', ->
    nikita
    .call -> true
    .call ({metadata}) ->
      metadata.position.should.eql [0, 1]
      await @call ({metadata}) ->
        metadata.position.should.eql [0, 1, 0]
      await @call ({metadata}) ->
        metadata.position.should.eql [0, 1, 1]

  it 'honors `metadata.bastard`', ->
    nikita
    .call -> true
    .call ({metadata}) ->
      metadata.position.should.eql [0, 1]
      await @call $bastard: true, ({metadata}) ->
        metadata.position.should.eql [0, 1, 0]
      await @call ({metadata}) ->
        metadata.position.should.eql [0, 1, 0]
