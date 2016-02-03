
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api shy', ->

  scratch = test.scratch @

  it 'dont alter status', (next) ->
    mecano
    .write
      destination: "#{scratch}/file_1"
      content: 'abc'
      shy: true
    .write
      destination: "#{scratch}/file_1"
      content: 'abc'
    .then (err, status) ->
      status.should.be.false() unless err
      next err

  it 'callback receive status', (next) ->
    mecano
    .write
      destination: "#{scratch}/file_1"
      content: 'abc'
      shy: true
    , (err, status) ->
      status.should.be.true()
    .then (err, status) ->
      status.should.be.false()
      next()

  it 'dont alter status', (next) ->
    mecano
    .call ->
      @write
        destination: "#{scratch}/file_1"
        content: 'abc'
        shy: true
    .then (err, status) ->
      status.should.be.false() unless err
      next err

  it 'array options', (next) ->
    count = 0
    mecano
    .write [
      destination: "#{scratch}/file_1"
      content: 'abc'
      shy: true
    ,
      destination: "#{scratch}/file_1"
      content: 'abc'
      shy: false
    ], (err, status) ->
      if count is 0
      then status.should.be.true()
      else status.should.be.false()
      count++
    .then (err, status) ->
      status.should.be.false()
    .write [
      destination: "#{scratch}/file_2"
      content: 'abc'
      shy: false
    ,
      destination: "#{scratch}/file_2"
      content: 'abc'
      shy: true
    ], (err, status) ->
      if count is 2
      then status.should.be.true()
      else status.should.be.false()
      count++
    .then (err, status) ->
      status.should.be.true() unless err
      next err
        
