
nikita = require '../../../src'
registry = require '../../../src/registry'
register = require '../../../src/register'
{tags} = require '../../test'

return unless tags.api

describe 'plugins.metadata.depth', ->

  it 'start at 0', ->
    nikita ({metadata}) ->
      metadata.depth.should.eql 0
      
  it 'is incremented and decremented', ->
    nikita
    .call ({metadata}) ->
      metadata.depth.should.eql 1
      @call ({metadata}) ->
        metadata.depth.should.eql 2
        @call ({metadata}) ->
          metadata.depth.should.eql 3
      @call ({metadata}) ->
        metadata.depth.should.eql 2
        @call ({metadata}) ->
          metadata.depth.should.eql 3

  it 'start at depth 0 with registered action', ->
    registry.register [], ({metadata}) ->
      key: "root value, depth #{metadata.depth}"
    {key} = await nikita()
    key.should.eql 'root value, depth 0'
    registry.unregister [], register['']

  it 'start at depth 0 with action argument', ->
    {key} = await nikita ({metadata}) ->
      key: "root value, depth #{metadata.depth}"
    key.should.eql 'root value, depth 0'
