
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "tolerant"', ->

  it.skip 'stop once errorless', ->
    called = false
    nikita
    .call () ->
      Error 'Oh no'
    .call tolerant: true, ->
      called = true
    .next (err) ->
      err.message.should.eql 'Oh no'
      called.should.be.true()
    .promise()
