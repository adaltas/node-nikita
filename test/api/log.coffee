
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api log', ->

  scratch = test.scratch @
  
  it 'pass objects', (next) ->
    log = null
    mecano
      log: (msg) -> log = msg
      log_serializer: false
    .call (options) ->
      options.log 'handler'
    .then (err) ->
      log.level.should.eql 'INFO'
      log.message.should.eql 'handler'
      (log.module is undefined).should.be.true()
      log.time.should.match /\d+/
      log.depth.should.eql 1
      next err
      
  it 'serialize into string with default serializer', (next) ->
    log = null
    mecano
      log: (msg) -> log = msg
      log_serializer: true
    .call (options) ->
      options.log 'handler'
    .then (err) ->
      log.should.match /^\[INFO \d+\] handler/ unless err
      next err
      
  it 'serialize into string with user serializer', (next) ->
    log = null
    mecano
      log: (msg) -> log = msg
      log_serializer: (log) -> "[#{log.level}] #{log.message}"
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
      log: (msg) -> log.push msg
    .call ->
      @log 'handler'
    , (err, status) ->
      @log 'callback' unless err
    .then (err) ->
      logs
      .map (log) -> log.message
      .should.eql ['handler', 'callback'] unless err
      next err
    
