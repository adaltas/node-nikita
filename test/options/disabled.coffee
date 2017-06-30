
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "disable"', ->

  scratch = test.scratch @

  it 'dont call handler', (next) ->
    nikita
    .call
      disabled: true
    , (otions) ->
      throw Error 'Achtung'
    .then next

  it 'emit lifecycle event when disabled', (next) ->
    nikita
    .call
      disabled: true
    , (otions) ->
      throw Error 'Achtung'
    .on 'lifecycle', (log) ->
      log.type.should.eql 'lifecycle'
      log.message.should.eql 'disabled_true'
      log.index.should.eql 0
      log.depth.should.eql 0
      (log.error is null).should.be.true()
      log.status.should.be.false()
      log.level.should.eql 'INFO'
      (log.module is undefined).should.be.true()
      log.header_depth.should.eql 0
      log.file.should.eql 'context.coffee.md'
      next()

  it 'emit lifecycle event when not disabled', (next) ->
    nikita
    .call
      disabled: false
    , (otions) ->
      throw Error 'Achtung'
    .on 'lifecycle', (log) ->
      log.type.should.eql 'lifecycle'
      log.message.should.eql 'disabled_false'
      log.index.should.eql 0
      log.depth.should.eql 0
      (log.error is null).should.be.true()
      log.status.should.be.false()
      log.level.should.eql 'DEBUG'
      (log.module is undefined).should.be.true()
      log.header_depth.should.eql 0
      log.file.should.eql 'context.coffee.md'
      next()
