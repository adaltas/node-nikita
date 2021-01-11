
nikita = require '../../../src'
registry = require '../../../src/registry'
register = require '../../../src/register'
{tags} = require '../../test'

return unless tags.api

describe 'plugins.metadata.index', ->

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
