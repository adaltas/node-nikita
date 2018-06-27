
nikita = require '../../src'
test = require '../test'

describe 'api end', ->

  it 'honor conditions', ->
    nikita
    .end if: false
    .call (_, handler) -> handler null, true # Set status to true
    .end if: true
    .call ({}, callback) -> next Error "Should never get here"
    .next (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  it 'inside callback', ->
    nikita
    .call (_, handler) ->
      handler null, true # Set status to true
    , ->
      @end()
    .call ({}, callback) -> callback Error 'Should never get here'
    .promise()
