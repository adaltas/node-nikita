
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "shy"', ->

  scratch = test.scratch @

  it 'dont alter status', ->
    nikita
    .file
      target: "#{scratch}/file_1"
      content: 'abc'
      shy: true
    .file
      target: "#{scratch}/file_1"
      content: 'abc'
    .then (err, status) ->
      status.should.be.false() unless err
    .promise()

  it 'callback receive status', ->
    nikita
    .file
      target: "#{scratch}/file_1"
      content: 'abc'
      shy: true
    , (err, status) ->
      status.should.be.true()
    .then (err, status) ->
      status.should.be.false()
    .promise()

  it 'dont alter status', ->
    nikita
    .call ->
      @file
        target: "#{scratch}/file_1"
        content: 'abc'
        shy: true
    .then (err, status) ->
      status.should.be.false() unless err
    .promise()

  it 'array options', ->
    count = 0
    nikita
    .file [
      target: "#{scratch}/file_1"
      content: 'abc'
      shy: true
    ,
      target: "#{scratch}/file_1"
      content: 'abc'
      shy: false
    ], (err, status) ->
      if count is 0
      then status.should.be.true()
      else status.should.be.false()
      count++
    .then (err, status) ->
      status.should.be.false()
    .file [
      target: "#{scratch}/file_2"
      content: 'abc'
      shy: false
    ,
      target: "#{scratch}/file_2"
      content: 'abc'
      shy: true
    ], (err, status) ->
      if count is 2
      then status.should.be.true()
      else status.should.be.false()
      count++
    .then (err, status) ->
      status.should.be.true() unless err
    .promise()
  
  it 'dont interferce with previous status', ->
    nikita
    .call shy: true, (err, callback)->
      callback null, true
    .call ->
      @status(-1).should.be.true()
    .then (err, status) ->
      # @status(-2).should.be.true() # TODO, not ready yet, stack is empty before then
      status.should.be.false() unless err
    .promise()
    
        
