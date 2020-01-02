
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'metadata "log"', ->
  
  it 'convert string to objects', ->
    logs = []
    nikita
    .call
      log: (log) -> logs.push log if log.type is 'text'
      handler: -> @log 'handler'
    .call ->
      logs.length.should.eql 1
      logs[0].level.should.eql 'INFO'
      logs[0].message.should.eql 'handler'
      (logs[0].module is undefined).should.be.true()
      logs[0].time.should.be.a.Number()
      logs[0].depth.should.eql 1
    .promise()

  it 'work recursively', ->
    logs = []
    nikita
    .call
      log: (log) -> logs.push log if log.type is 'text'
      handler: ->
        @call ->
          @log 'handler'
    .call ->
      logs.length.should.eql 1
      logs[0].level.should.eql 'INFO'
      logs[0].message.should.eql 'handler'
      (logs[0].module is undefined).should.be.true()
      logs[0].time.should.be.a.Number()
      logs[0].depth.should.eql 2
    .promise()

  it 'is cascaded to conditions when true', ->
    logs = []
    nikita
    .on 'text', (log) ->
      logs.push log.message
    .call
      log: false
      if: (action) ->
        action.metadata.log.should.be.false()
        @log 'inside condition'
    , (->)
    .next (err) ->
      throw err if err
      logs.should.eql []
    .promise()

  it 'is cascaded to conditions when false', ->
    logs = []
    nikita
    .on 'text', (log) ->
      logs.push log.message
    .call
      log: true
      if: ({metadata}) ->
        metadata.log.should.be.true()
        @log 'inside condition'
    , (->)
    .next (err) ->
      throw err if err
      logs.should.eql ['inside condition']
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
          handler: ->
            @log 'handler'
    .call ->
      logs_parent.length.should.eql 0
      logs_child.length.should.eql 1
      logs_child[0].level.should.eql 'INFO'
      logs_child[0].message.should.eql 'handler'
      (logs_child[0].module is undefined).should.be.true()
      logs_child[0].time.should.be.a.Number()
      logs_child[0].depth.should.eql 2
    .promise()

  it 'false disable logging', ->
    log = null
    nikita
    .on 'text', ({message}) ->
      log = message
    .call ->
      @log 'is nikita around'
    .call
      log: true
    , ->
      @call
        log: false
      , ->
        @log 'no, u wont find her'
    .call ->
      log.should.eql 'is nikita around'
    .promise()

  it 'true enable logging', ->
    logs = []
    nikita
    .on 'text', ({message}) ->
      logs.push message
    .call ->
      @log 'is nikita around'
    .call
      call: false
    , ->
      @call
        log: true
      , ->
        @log 'yes it is'
    .call ->
      logs.should.eql ['is nikita around', 'yes it is']
    .promise()

  it 'can be safely passed to the options of a child handler', ->
    # Fix a bug in which the child log "yes, dont kill her was called twice"
    logs = []
    nikita
    .on 'text', ({message}) ->
      logs.push message
    .call ({options}) ->
      @log 'is nikita around'
      @call
        log: options.log
      , ->
        @log 'yes, dont kill her'
    .call ->
      logs.should.eql ['is nikita around', 'yes, dont kill her']
    .promise()
