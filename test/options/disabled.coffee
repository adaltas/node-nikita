
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

  it 'emit log type "disabled"', (next) ->
    nikita
    .call
      disabled: true
    , (otions) ->
      throw Error 'Achtung'
    .on 'disabled', (log) ->
      log.type.should.eql 'disabled'
      log.index.should.eql 0
      log.depth.should.eql 0
      (log.error is null).should.be.true()
      log.status.should.be.false()
      log.level.should.eql 'INFO'
      (log.module is undefined).should.be.true()
      log.header_depth.should.eql 0
      log.file.should.eql 'context.coffee.md'
      next()
