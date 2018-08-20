
fs = require 'fs'
path = require 'path'
nikita = require '../../src'
test = require '../test'

describe 'log', ->

  scratch = test.scratch @

  it 'string is converted to message', ->
    startTS = Date.now()
    nikita
    .call ->
      @log 'some text'
    .on 'text', (log) ->
      # There should be only on log emited, thus
      # there is no need to filter incoming logs
      Object.keys(log).sort().should.eql [
        'argument', 'depth', 'file', 'headers'
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
