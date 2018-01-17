
nikita = require '../../src'
test = require '../test'

describe 'options "status"', ->
  
  it 'dont pass status in callback', ->
    nikita
    .call status: false, (_, callback) ->
      callback null, 'a message'
    , (err, message) ->
      message.should.eql 'a message' unless err
    .promise()
      
  it 'dont modify status', ->
    nikita
    .call ->
      @call status: false, (_, callback) ->
        callback null, 'something'
    , (err, status) ->
      status.should.be.false() unless err
    .call ->
      @status().should.be.false()
    .promise()
