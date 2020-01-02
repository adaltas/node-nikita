
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
      # There should be only one log emited, thus
      # there is no need to filter incoming logs
      (count++).should.eql 0
      Object.keys(log).sort().should.eql [
        'depth',    'file',
        'index',    'level',
        'line',     'message',
        'metadata', 'module',
        'options',  'parent',
        'time',     'type'
      ]
      log.depth.should.eql 1
      (log.index is undefined).should.be.true()
      log.level.should.eql 'INFO'
      log.line.should.be.a.Number()
      log.message.should.eql 'some text'
      (log.module is undefined).should.be.true()
      log.time.should.be.within startTS, Date.now()
      log.type.should.eql 'text'
      log.metadata.argument.should.eql 'some text'
      log.parent.metadata.headers.should.eql []
    .promise()
