
nikita = require '../../src'
test = require '../test'

describe 'api end', ->

  it 'honor conditions', (next) ->
    nikita
    .end if: false
    .call (_, handler) -> handler null, true # Set status to true
    .end if: true
    .call ({}, callback) -> next Error "Should never get here"
    .then (err, status) ->
      return next err if err
      return next Error 'False condition not honored' unless status
      return next()

  it 'inside callback', (next) ->
    nikita
    .call (_, handler) ->
      handler null, true # Set status to true
    , (err, status) ->
      @end()
    .call ({}, callback) -> next Error "Should never get here"
    .then (err, status) ->
      return next err

  # Doest work yet, need to spec clarification
  # it 'inside call', (next) ->
  #   nikita
  #   .call (_, handler) ->
  #     @end()
  #     # handler null, true # Set status to true
  #   .call ({}, callback) -> next Error "Should never get here"
  #   .then (err, status) ->
  #     return next err

      
