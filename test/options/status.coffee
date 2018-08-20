
nikita = require '../../src'
test = require '../test'

describe 'options "status"', ->
  
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
