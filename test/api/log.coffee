
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api log', ->

  scratch = test.scratch @
  
  it 'pass objects', (next) ->
    log = null
    mecano
    .on 'text', (l) -> log = l
    .call (options) -> options.log 'handler'
    .then (err) ->
      log.level.should.eql 'INFO'
      log.message.should.eql 'handler'
      (log.module is undefined).should.be.true()
      log.time.should.match /\d+/
      log.total_depth.should.eql 1
      next err
      
  it.skip 'serialize into string with default serializer', (next) ->
    # log_serializer isnt yet activated
    log = null
    mecano
      log_serializer: true
    .on 'text', (l) -> log = l
    .call (options) ->
      options.log 'handler'
    .then (err) ->
      log.should.match /^\[INFO \d+\] handler/ unless err
      next err
      
  it.skip 'serialize into string with user serializer', (next) ->
    # log_serializer isnt yet activated
    log = null
    mecano
      log_serializer: (log) -> "[#{log.level}] #{log.message}"
    .on 'text', (l) -> log = l
    .call (options) ->
      options.log 'handler'
    .then (err) ->
      log.should.eql "[INFO] handler" unless err
      next err
      
  it.skip 'print value', (next) ->
    # Doesnt work for now
    # The idea is that log shouldnt be an option
    # But be part of mecano context
    # which will make it also available inside callbacks
    logs = []
    mecano
    .on 'text', (l) -> log.push l
    .call ->
      @log 'handler'
    , (err, status) ->
      @log 'callback' unless err
    .then (err) ->
      logs
      .map (log) -> log.message
      .should.eql ['handler', 'callback'] unless err
      next err
    
