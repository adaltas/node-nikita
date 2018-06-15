
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "disable"', ->

  scratch = test.scratch @

  it 'dont call handler', ->
    nikita
    .call
      disabled: true
    , (otions) ->
      throw Error 'Achtung'
    .promise()

  it 'emit lifecycle event when disabled', ->
    nikita
    .call
      disabled: true
    , (otions) ->
      throw Error 'Achtung'
    .on 'lifecycle', (log) ->
      Object.keys(log).sort().should.eql [
        'depth', 'error', 'file', 'headers', 'index', 
        'level', 'line', 'message', 'module', 'shy', 
        'status', 'time', 'type'
      ]
      log.depth.should.eql 1
      (log.error is null).should.be.true()
      log.headers.should.eql []
      log.index.should.eql 0
      log.level.should.eql 'INFO'
      log.message.should.eql 'disabled_true'
      (log.module is undefined).should.be.true()
      log.shy.should.be.true()
      log.status.should.be.false()
      log.type.should.eql 'lifecycle'
      # log.file.should.eql 'context.coffee.md'
    .promise()

  it 'emit lifecycle event when not disabled', ->
    nikita
    .call
      disabled: false
    , (otions) ->
      throw Error 'Achtung'
    .on 'lifecycle', (log) ->
      return if log.message is 'conditions_passed'
      log.type.should.eql 'lifecycle'
      log.message.should.eql 'disabled_false'
      log.index.should.eql 0
      (log.error is null).should.be.true()
      log.status.should.be.false()
      log.level.should.eql 'DEBUG'
      (log.module is undefined).should.be.true()
      log.headers.should.eql []
      log.file.should.eql 'context.coffee.md'
    .next (->)
    .promise()
