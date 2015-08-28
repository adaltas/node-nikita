
mecano = require '../../src'
test = require '../test'
fs = require 'fs'
domain = require 'domain'

describe 'api call', ->

  scratch = test.scratch @

  describe 'sync', ->

    it 'execute a handler', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/file_a"
      , (err) ->
        touched++
      .call (options) ->
        called++
      .touch
        destination: "#{scratch}/file_b"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it.skip 'execute a callback', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call ((options) ->), (err, status) ->
        called++ unless err
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1
        touched.should.eql 2
        next()

    it 'pass options', (next) ->
      mecano
      .call test: true, (options) ->
        options.test.should.be.true()
      .then next

    it 'pass multiple options', (next) ->
      mecano
      .call {test1: true}, {test2: true}, (options) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
      .then next

  describe 'async', ->

    it 'execute a handler', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call (options, next) ->
        process.nextTick ->
          called++
          next()
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it 'execute a callback', (next) ->
      called = 0
      touched = 0
      mecano
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call (options, next) ->
        process.nextTick ->
          next()
      , (err, status) ->
        called++ unless err
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1 unless err
        touched.should.eql 2 unless err
        next err

    it 'pass options', (next) ->
      mecano
      .call test: true, (options, next) ->
        options.test.should.be.true()
        next()
      .then next

    it 'pass multiple options', (next) ->
      mecano
      .call {test1: true}, {test2: true}, (options, next) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
        next()
      .then next

  describe 'async err', ->

    it 'thrown', (next) ->
      mecano
      .call (options, next) ->
        throw Error 'Catchme'
      .then (err, status) ->
        err.message.should.eql 'Catchme'
        next()

    it 'pass to next', (next) ->
      mecano
      .call (options, next) ->
        process.nextTick ->
          next Error 'Catchme'
      .then (err, status) ->
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
        .call (options, next) ->
          next.property.does.not.exist
        .call (options) ->
          console.log 'Shouldnt be called'
          next Error 'Shouldnt be called'
        , (err) ->
      d.on 'error', (err) ->
        err.name.should.eql 'TypeError'
        d.exit()
        next()

    it 'catch error in next tick', (next) ->
      mecano
      .call (options, next) ->
        process.nextTick ->
          next Error 'Catchme'
      .then (err, status) ->
        err.message.should.eql 'Catchme'
        next()
        # setTimeout next, 100000

  describe 'async nested', ->

    it 'in a user callback', (next) ->
      m = mecano
      .call (options, next) ->
        @write
          content: 'ok'
          destination: "#{scratch}/a_file"
        , next
      .then (err, status) ->
        fs.readFile "#{scratch}/a_file", 'ascii', (err, content) ->
          next()

    it 'in then with changes', (next) ->
      m = mecano
      .call (options, next) ->
        @write
          content: 'ok'
          destination: "#{scratch}/a_file"
        .then next
      .then (err, status) ->
        status.should.be.true()
        fs.readFile "#{scratch}/a_file", 'ascii', (err, content) ->
          next()

    it 'in then without changes', (next) ->
      m = mecano
      .call (options, next) ->
        @write
          content: 'ok'
          destination: "#{scratch}/a_file"
          if_exists: "#{scratch}/a_file"
        .then next
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'pass user arguments', (next) ->
      callback_called = false
      m = mecano
      .call (options, next) ->
        setImmediate ->
          next null, true, 'argument'
      , (err, status, argument) ->
        callback_called = true
        status.should.be.true()
        argument.should.equal 'argument'
      .then (err, status) ->
        callback_called.should.be.true() unless err
        status.should.be.true() unless err
        next err

        






