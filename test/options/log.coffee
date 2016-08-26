
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options log', ->

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
        
    it 'work recursively', (next) ->
      logs = []
      mecano
      .call
        log: (l) -> logs.push l
        handler: ->
          @call (options) ->
              options.log 'handler'
      .then (err) ->
        logs.length.should.eql 1
        logs[0].level.should.eql 'INFO'
        logs[0].message.should.eql 'handler'
        (logs[0].module is undefined).should.be.true()
        logs[0].time.should.match /\d+/
        logs[0].total_depth.should.eql 2
        next err
        
    it 'is overwritteable', (next) ->
      logs_parent = []
      logs_child = []
      mecano
      .call 
        log: (l) -> logs_parent.push l
        handler: ->
          @call
            log: (l) -> logs_child.push l
            handler: (options) ->
              options.log 'handler'
      .then (err) ->
        logs_parent.length.should.eql 0
        logs_child.length.should.eql 1
        logs_child[0].level.should.eql 'INFO'
        logs_child[0].message.should.eql 'handler'
        (logs_child[0].module is undefined).should.be.true()
        logs_child[0].time.should.match /\d+/
        logs_child[0].total_depth.should.eql 2
        next err
  
    it 'disable if set to false', (next) ->
      log = null
      mecano
      .on 'text', ({message}) ->
        log = message
      .call
        handler: (options) ->
          options.log 'is nikita around'
      .call
        log: false
        handler: (options) ->
          options.log 'no, u wont find her'
      .then (err) ->
        log.should.eql 'is nikita around' unless err
        next err
  
    it 'can be safely passed to the options of a child handler', (next) ->
      # Fix a bug in which the child log "yes, dont kill her was called twice"
      logs = []
      mecano
      .on 'text', ({message}) ->
        logs.push message
      .call (options) ->
        options.log 'is nikita around'
        @call
          log: options.log
          handler: (options) ->
            options.log 'yes, dont kill her'
      .then (err) ->
        logs.should.eql ['is nikita around', 'yes, dont kill her'] unless err
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
    
