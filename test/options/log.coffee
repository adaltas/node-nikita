
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "log"', ->

  scratch = test.scratch @
  
  describe 'local via log option', ->
  
    it 'convert string to objects', ->
      logs = []
      nikita
      .call
        log: (l) -> logs.push l if l.type is 'text'
        handler: (options) -> options.log 'handler'
      .call ->
        logs.length.should.eql 1
        logs[0].level.should.eql 'INFO'
        logs[0].message.should.eql 'handler'
        (logs[0].module is undefined).should.be.true()
        logs[0].time.should.be.a.Number()
        logs[0].total_depth.should.eql 1
      .promise()

    it 'work recursively', ->
      logs = []
      nikita
      .call
        log: (l) -> logs.push l if l.type is 'text'
        handler: ->
          @call (options) ->
              options.log 'handler'
      .call ->
        logs.length.should.eql 1
        logs[0].level.should.eql 'INFO'
        logs[0].message.should.eql 'handler'
        (logs[0].module is undefined).should.be.true()
        logs[0].time.should.be.a.Number()
        logs[0].total_depth.should.eql 2
      .promise()

    it 'is overwritteable', ->
      logs_parent = []
      logs_child = []
      nikita
      .call
        log: (l) -> logs_parent.push l if l.type is 'text'
        handler: ->
          @call
            log: (l) -> logs_child.push l if l.type is 'text'
            handler: (options) ->
              options.log 'handler'
      .call ->
        logs_parent.length.should.eql 0
        logs_child.length.should.eql 1
        logs_child[0].level.should.eql 'INFO'
        logs_child[0].message.should.eql 'handler'
        (logs_child[0].module is undefined).should.be.true()
        logs_child[0].time.should.be.a.Number()
        logs_child[0].total_depth.should.eql 2
      .promise()
  
    it 'disable if set to false', ->
      log = null
      nikita
      .on 'text', ({message}) ->
        log = message
      .call
        handler: (options) ->
          options.log 'is nikita around'
      .call
        log: false
        handler: (options) ->
          options.log 'no, u wont find her'
      .call ->
        log.should.eql 'is nikita around'
      .promise()
  
    it 'can be safely passed to the options of a child handler', ->
      # Fix a bug in which the child log "yes, dont kill her was called twice"
      logs = []
      nikita
      .on 'text', ({message}) ->
        logs.push message
      .call (options) ->
        options.log 'is nikita around'
        @call
          log: options.log
          handler: (options) ->
            options.log 'yes, dont kill her'
      .call ->
        logs.should.eql ['is nikita around', 'yes, dont kill her']
      .promise()
  
  describe 'global via on', ->
  
    it 'convert string to objects', ->
      logs = []
      nikita
      .on 'text', (l) -> logs.push l
      .call (options) -> options.log 'handler'
      .call ->
        logs.length.should.eql 1
        logs[0].level.should.eql 'INFO'
        logs[0].message.should.eql 'handler'
        (logs[0].module is undefined).should.be.true()
        logs[0].time.should.be.a.Number()
        logs[0].total_depth.should.eql 1
      .promise()
      
  it.skip 'serialize into string with default serializer', ->
    # log_serializer isnt yet activated
    log = null
    nikita
      log_serializer: true
    .on 'text', (l) -> log = l
    .call (options) ->
      options.log 'handler'
    .call ->
      log.should.match /^\[INFO \d+\] handler/
    .promise()
      
  it.skip 'serialize into string with user serializer', ->
    # log_serializer isnt yet activated
    log = null
    nikita
      log_serializer: (log) -> "[#{log.level}] #{log.message}"
    .on 'text', (l) -> log = l
    .call (options) ->
      options.log 'handler'
    .call ->
      log.should.eql "[INFO] handler"
    .promise()
      
  it.skip 'print value', ->
    # Doesnt work for now
    # The idea is that log shouldnt be an option
    # But be part of nikita context
    # which will make it also available inside callbacks
    logs = []
    nikita
    .on 'text', (l) -> log.push l
    .call ->
      @log 'handler'
    , (err, status) ->
      @log 'callback' unless err
    .call ->
      logs
      .map (log) -> log.message
      .should.eql ['handler', 'callback']
    .promise()
