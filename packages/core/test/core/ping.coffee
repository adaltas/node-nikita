
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'ping', ->

  they 'arguments', ({ssh}) ->
    nikita
      ssh: ssh
    .core.ping (err, {status, message}) ->
      (err is undefined).should.be.true()
      status.should.be.true()
      message.should.eql 'pong'
    .promise()

  they 'log', ({ssh}) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) ->
      logs.push log
    .core.ping (err, {status, message}) ->
      logs.map( (log) -> log.message).should.eql [
        'Entering ping'
        'Sending pong'
      ]
    .promise()
