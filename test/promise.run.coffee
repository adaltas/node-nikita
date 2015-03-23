
mecano = require '../src'
test = require './test'
fs = require 'fs'
domain = require 'domain'

describe 'promise run', ->

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
      .run ->
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
      .run ->
        return true
      .then (err, changed) ->
        changed.should.be.True
        next()

    it 'set changed to false', (next) ->
      mecano
      .run ->
        return false
      .then (err, changed) ->
        changed.should.be.False
        next()

    it 'catch error', (next) ->
      mecano
      .run ->
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
      .run (next) ->
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
      .run (next) ->
        process.nextTick ->
          next null, true
      .then (err, changed) ->
        changed.should.be.True
        next()

    it 'set changed to false', (next) ->
      mecano
      .run (next) ->
        process.nextTick ->
          next null, false
      .then (err, changed) ->
        changed.should.be.False
        next()

    it 'catch error', (next) ->
      mecano
      .run (next) ->
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
        .run (next) ->
          next.property.does.not.exist
        .run ->
          next Error 'Shouldnt be called'
        , (err) ->
          console.log 'ok', err
      d.on 'error', (err) ->
        err.name.should.eql 'TypeError'
        next()

    it 'catch error in next tick', (next) ->
      mecano
      .run (next) ->
        process.nextTick ->
          next Error 'Catchme'
      .then (err, changed) ->
        err.message.should.eql 'Catchme'
        next()

        






