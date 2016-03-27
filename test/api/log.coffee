
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api log', ->

  scratch = test.scratch @
  
  describe 'local via log option', ->
  
    it 'convert string to objects', (next) ->
      logs = []
      mecano
      .call 
        log: (l) -> logs.push l
        handler: (options) -> options.log 'handler'
      .then (err) ->
        logs.length.should.eql 1
        logs[0].level.should.eql 'INFO'
        logs[0].message.should.eql 'handler'
        (logs[0].module is undefined).should.be.true()
        logs[0].time.should.match /\d+/
        logs[0].total_depth.should.eql 1
        next err
  
  describe 'global via on', ->
  
    it 'convert string to objects', (next) ->
      logs = []
      mecano
      .on 'text', (l) -> logs.push l
      .call (options) -> options.log 'handler'
      .then (err) ->
        logs.length.should.eql 1
        logs[0].level.should.eql 'INFO'
        logs[0].message.should.eql 'handler'
        (logs[0].module is undefined).should.be.true()
        logs[0].time.should.match /\d+/
        logs[0].total_depth.should.eql 1
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
    
