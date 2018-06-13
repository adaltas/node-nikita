
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
      log.type.should.eql 'lifecycle'
      log.message.should.eql 'disabled_true'
      log.index.should.eql 0
      (log.error is null).should.be.true()
      log.status.should.be.false()
      log.level.should.eql 'INFO'
      (log.module is undefined).should.be.true()
      log.headers.should.eql []
      log.file.should.eql 'context.coffee.md'
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
