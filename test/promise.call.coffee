
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
      .call (options) ->
        called++
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1
        touched.should.eql 2
        next()

    it 'set status to true', (next) ->
      mecano
      .call (options) ->
        return true
      .then (err, status) ->
        status.should.be.true()
        next()

    it 'set status to false', (next) ->
      mecano
      .call (options) ->
        return false
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'catch error', (next) ->
      mecano
      .call (options) ->
        throw Error 'Catchme'
      .then (err, status) ->
        err.message.should.eql 'Catchme'
        next()

    # it 'register new actions', (next) ->
    #   mecano
    #   .call ->
    #     return false
    #   .then (err, status) ->
    #     status.should.be.false()
    #     next()

  describe 'async', ->

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
          called++
          next()
      .touch
        destination: "#{scratch}/a_file"
      , (err) ->
        touched++
      .then (err, status) ->
        called.should.eql 1
        touched.should.eql 2
        next()

    it 'set status to true', (next) ->
      mecano
      .call (options, next) ->
        process.nextTick ->
          next null, true
      .then (err, status) ->
        status.should.be.true()
        next()

    it 'set status to false', (next) ->
      mecano
      .call (options, next) ->
        process.nextTick ->
          next null, false
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'set status to false while child module is true', (next) ->
      m = mecano()
      .call (options, callback) ->
        m.execute
          cmd: 'ls -l'
        , (err, executed, stdout, stderr) ->
          executed.should.be.true() unless err
          callback err, false
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'set status to true while module sending is false', (next) ->
      m = mecano()
      .call (options, callback) ->
        m.execute
          cmd: 'ls -l'
          if: false
        , (err, executed, stdout, stderr) ->
          executed.should.be.false() unless err
          callback err, true
      .then (err, status) ->
        status.should.be.true()
        next()

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

        






