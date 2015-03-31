
mecano = require '../src'
test = require './test'
fs = require 'fs'
domain = require 'domain'

describe 'promise call', ->

  scratch = test.scratch @

  describe 'sync', ->

    it 'execute a callback', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call ->
        called++
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, changed) ->
        called.should.eql 1
        touched.should.eql 2
        next()

    it 'set changed to true', (next) ->
      mecano
      .call ->
        return true
      .then (err, changed) ->
        changed.should.be.True
        next()

    it 'set changed to false', (next) ->
      mecano
      .call ->
        return false
      .then (err, changed) ->
        changed.should.be.False
        next()

    it 'catch error', (next) ->
      mecano
      .call ->
        throw Error 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

  describe 'async', ->

    it 'execute a callback', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call (next) ->
        process.nextTick ->
          called++
          next()
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, changed) ->
        called.should.eql 1
        touched.should.eql 2
        next()

    it 'set changed to true', (next) ->
      mecano
      .call (next) ->
        process.nextTick ->
          next null, true
      .then (err, changed) ->
        changed.should.be.True
        next()

    it 'set changed to false', (next) ->
      mecano
      .call (next) ->
        process.nextTick ->
          next null, false
      .then (err, changed) ->
        changed.should.be.False
        next()

    it 'catch error', (next) ->
      mecano
      .call (next) ->
        throw Error 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

    it 'throw error when then not defined', (next) ->
      d = domain.create()
      d.run ->
        mecano
        .touch
          destination: "#{scratch}/a_file"
        , (err) ->
          false
        .call (next) ->
          next.property.does.not.exist
        .call ->
          next Error 'Shouldnt be called'
        , (err) ->
          console.log 'ok', err
      d.on 'error', (err) ->
        err.name.should.eql 'TypeError'
        next()

    it 'catch error in next tick', (next) ->
      mecano
      .call (next) ->
        process.nextTick ->
          next Error 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

        






