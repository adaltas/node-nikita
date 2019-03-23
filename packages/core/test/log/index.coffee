
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'log', ->

  it 'string is converted to message', ->
    count = 0
    startTS = Date.now()
    nikita
    .call ->
      @log 'some text'
    .on 'text', (log) ->
      (count++).should.eql 0
      # There should be only on log emited, thus
      # there is no need to filter incoming logs
      Object.keys(log).sort().should.eql [
        'argument', 'attempt', 'depth', 'disabled', 'file', 'headers'
        'level', 'line', 'message', 'module'
        'shy', 'status', 'time', 'type'
      ]
      log.argument.should.eql 'some text'
      log.level.should.eql 'INFO'
      log.message.should.eql 'some text'
      (log.module is undefined).should.be.true()
      log.time.should.be.within startTS, Date.now()
      log.type.should.eql 'text'
      log.headers.should.eql []
      log.depth.should.eql 1
    .promise()
