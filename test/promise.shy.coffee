
mecano = require '../src'
test = require './test'
fs = require 'fs'

describe 'promise shy', ->

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
      status.should.be.false()
      next()

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

  it 'array options', (next) ->
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
      status.should.be.true()
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
      status.should.be.true() unless err
    .then (err, status) ->
      status.should.be.true() unless err
      next err
        






