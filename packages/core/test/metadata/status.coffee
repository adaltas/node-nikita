
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "status"', ->
  
  it 'pass arguments', ->
    nikita
    .call status: false, (_, callback) ->
      callback null, status: true, message: 'a message'
    , (err, {status, message}) ->
      status.should.be.true()
      message.should.eql 'a message'
    .promise()
      
  it 'dont modify session status', ->
    nikita
    .call status: false, (_, callback) ->
      callback null, status: true
    .call ->
      @status(-1).should.be.false()
      @status().should.be.false()
    .promise()
