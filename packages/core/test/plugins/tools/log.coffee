
{tags} = require '../../test'
nikita = require '../../../lib'
stream = require 'stream'

describe 'plugins.tools.log', ->
  return unless tags.api

  describe 'events', ->
    
    it 'emitted and readable by events', ->
      nikita ({tools: {events, log}}) ->
        new Promise (resolve) ->
          events.on 'text', (msg) ->
            resolve msg
          log message: 'getme'
        .should.finally.containEql
          message: 'getme'
          level: 'INFO'
          index: 0
          module: undefined
          namespace: []
          type: 'text'
          depth: 0
          file: 'log.coffee'
          filename: __filename
          line: 23
          
    it 'argument is immutable', ->
      arg = key: 'value'
      await nikita.call ({tools: {log}}) ->
        log arg
        true
      arg.should.eql key: 'value'
  
  describe 'tools.log', ->

    it 'only strings and objects are accepted', ->
      nikita
        .call
          $log: ({log}) -> logs.push log
        , ({tools: {log}}) ->
          log 'a message', -1
      .should.be.rejectedWith [
        'TOOLS_LOGS_INVALID_ARGUMENT:'
        '`tools.log` accept string and object arguments,'
        'got -1.'
      ].join ' '

    it 'only 2 strings are accepted', ->
      nikita
        .call
          $log: ({log}) -> logs.push log
        , ({tools: {log}}) ->
          log 'a level', 'a message', 'an error'
      .should.be.rejectedWith [
        'TOOLS_LOGS_INVALID_STRING_ARGUMENT:'
        '`tools.log` accept only 2 strings,'
        'a level and a message, additionnal string arguments are not supported,'
        'got "an error".'
      ].join ' '

    it 'accept message:string', ->
      logs = []
      await nikita
        .call
          $log: ({log}) -> logs.push log
        , ({tools: {log}}) ->
          log 'a message'
      logs.map( ({message}) => message).should.eql ['a message']

    it 'accept level:string, message:string', ->
      logs = []
      await nikita
        .call
          $log: ({log}) -> logs.push log
        , ({tools: {log}}) ->
          log 'INFO', 'an information'
          log 'WARN', 'a warning'
      logs
        .map( ({level, message}) -> "#{level}: #{message}")
        .should.eql ['INFO: an information', 'WARN: a warning']

    it 'accept level:object, level:string, message:object, message:string', ->
      logs = []
      await nikita
        .call
          $log: ({log}) -> logs.push log
        , ({tools: {log}}) ->
          log level: 'INFO', 'ERROR', message: 'an info', 'an error'
          log level: 'DEBUG', 'WARN', message: 'a debug', 'a warning'
      logs
        .map( ({level, message}) -> "#{level}: #{message}")
        .should.eql ['ERROR: an error', 'WARN: a warning']

    it 'accept level:string, level:object, message:string, message:object', ->
      logs = []
      await nikita
        .call
          $log: ({log}) -> logs.push log
        , ({tools: {log}}) ->
          log 'INFO', level: 'ERROR', 'an info', message: 'an error'
          log 'DEBUG', level: 'WARN', 'a warning', message: 'a warning'
      logs
        .map( ({level, message}) -> "#{level}: #{message}")
        .should.eql ['ERROR: an error', 'WARN: a warning']

  
  describe 'metadata.log as a `boolean`', ->
      
    it 'equals `true`', ->
      data = []
      await nikita
      .call ({tools: {events}}) ->
        events.on 'text', (log) -> data.push log.message
      .call $log: true, ({tools: {log}}) ->
        log message: 'enabled parent'
        @call ({tools: {log}}) ->
          log message: 'enabled child'
      data.should.eql ['enabled parent', 'enabled child']
    
    it 'equals `false`', ->
      data = []
      await nikita
      .call ({tools: {events}}) ->
        events.on 'text', (log) -> data.push log.message
      .call $log: false, ({tools: {log}}) ->
        log message: 'disabled'
        @call ({tools: {log}}) ->
          log message: 'disabled child'
      data.should.eql []
    
    it 'equals `false` disabled with `metadata.debug`', ->
      data = []
      await nikita
        $debug: new stream.Writable write: (->)
      .call ({tools: {events}}) ->
        events.on 'text', (log) -> data.push log.message
      .call $log: false, ({tools: {log}}) ->
        log message: 'enabled parent'
        @call ({tools: {log}}) ->
          log message: 'enabled child'
      data.should.eql ['enabled parent', 'enabled child']
  
  describe 'metadata.log as a `function`', ->
  
    it 'argument `log`', ->
      data = []
      await nikita
      .call
        $log: ({log}) ->
          data.push log.message
      , ({tools: {log}}) ->
        log message: 'enabled parent'
        @call ({tools: {log}}) ->
          log message: 'enabled child'
      data.should.eql ['enabled parent', 'enabled child']
      
    it 'arguments', ->
      data = null
      await nikita
      .call
        $log: (args) ->
          data = Object.keys(args).sort()
      , ({tools: {log}}) ->
        log message: 'enabled parent'
      data.should.eql ['config', 'log', 'metadata']
