
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'ping', ->

  they 'arguments', (ssh, next) ->
    nikita
      ssh: ssh
    .core.ping (err, status, message) ->
      (err is undefined).should.be.true()
      status.should.be.true()
      message.should.eql 'pong'
    .then next

  they 'log', (ssh, next) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) ->
      logs.push log
    .core.ping (err, status, message) ->
      logs.map( (log) -> log.message).should.eql [
        'Entering ping'
        'Sending pong'
      ]
    .then next
