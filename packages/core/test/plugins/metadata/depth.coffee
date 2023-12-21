
import nikita from '@nikitajs/core'
import registry from '@nikitajs/core/registry'
import test from '../../test.coffee'

describe 'plugins.metadata.depth', ->
  return unless test.tags.api

  it 'start at 0', ->
    nikita ({metadata}) ->
      metadata.depth.should.eql 0
      
  it 'is incremented and decremented', ->
    nikita
    .call ({metadata}) ->
      metadata.depth.should.eql 1
      await @call ({metadata}) ->
        metadata.depth.should.eql 2
        await @call ({metadata}) ->
          metadata.depth.should.eql 3
      await @call ({metadata}) ->
        metadata.depth.should.eql 2
        await @call ({metadata}) ->
          metadata.depth.should.eql 3

  it 'start at depth 0 with registered action', ->
    registry.register [], ({metadata}) ->
      key: "root value, depth #{metadata.depth}"
    {key} = await nikita()
    key.should.eql 'root value, depth 0'
    # registry.unregister [], register['']
    registry.unregister []

  it 'start at depth 0 with action argument', ->
    {key} = await nikita ({metadata}) ->
      key: "root value, depth #{metadata.depth}"
    key.should.eql 'root value, depth 0'
