
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "deprecate"', ->

  it 'is incremented and decremented', ->
    nikita
    .call deprecate: true, relax: true, (->), (err) ->
      err.message.should.eql 'call is deprecated'
    .promise()
