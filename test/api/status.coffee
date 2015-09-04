
mecano = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api status', ->

  describe 'sync', ->

    it 'default to false', (next) ->
      mecano
      .call (options) ->
        return true
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'set status to true', (next) ->
      mecano
      .call (options) ->
        @call (_, callback) ->
          callback null, true
      .then (err, status) ->
        status.should.be.true()
        next()

    it 'set status to false', (next) ->
      mecano
      .call (options) ->
        @call (_, callback) ->
          callback null, false
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

  describe 'async', ->

    it 'set status to true', (next) ->
      mecano
      .call (options, next) ->
        process.nextTick ->
          next null, true
      .then (err, status) ->
        status.should.be.true() unless err
        next err

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

  describe 'function', ->

    it 'get without arguments', (next) ->
      mecano
      .call (options, callback) ->
        @status().should.be.false()
        callback null, false
      , (err, status) ->
        @status().should.be.false()
      .call (options, callback) ->
        @status().should.be.false()
        callback null, true
      .call (options, callback) ->
        @status().should.be.true()
        callback null, false
      .call (options, callback) ->
        @status().should.be.true()
        callback null, false
      .then next

    it 'get current', (next) ->
      mecano
      .call (options, callback) ->
        (@status(0) is undefined).should.be.true()
        callback null, false
      , (err, status) ->
        @status(0).should.be.false()
      .call (options, callback) ->
        (@status(0) is undefined).should.be.true()
        callback null, true
      , (err, status) ->
        @status(0).should.be.true()
      .then next

    it 'get previous', (next) ->
      mecano
      .call (options, callback) ->
        (@status(-1) is undefined).should.be.true()
        callback null, false
      , (err, status) ->
        (@status(-1) is undefined).should.be.true()
      .call (options, callback) ->
        @status(-1).should.be.false()
        callback null, true
      .call (options, callback) ->
        @status(-1).should.be.true()
        callback null, false
      .call (options, callback) ->
        @status(-1).should.be.false()
        callback null, false
      .then next

    it 'get previous n', (next) ->
      mecano
      .call (options, callback) ->
        callback null, false
      .call (options, callback) ->
        (@status(0) is undefined).should.be.true()
        @status(-1).should.be.false()
        callback null, false
      , (err, status) ->
        @status(0).should.be.false()
        @status(-1).should.be.false()
      .call (options, callback) ->
        callback null, true
      , (err, status) ->
        @status(0).should.be.true()
        @status(-1).should.be.false()
        @status(-2).should.be.false()
      .call (options, callback) ->
        (@status(0) is undefined).should.be.true()
        @status(-1).should.be.true()
        @status(-2).should.be.false()
        callback null, false
      .then next

    it 'report conditions', (next) ->
      mecano
      .call
        if: -> true
      , (options, callback) ->
        callback null, true
      .then (err, status) ->
        return next err if err
        status.should.be.true()
      .call
        if: -> false
      , (options, callback) ->
        callback null, true
      .then (err, status) ->
        return next err if err
        status.should.be.false()
        next()

    it 'retrieve inside conditions', (next) ->
      mecano
      .call
        if: -> @status()
      , (options, callback) -> 
        callback Error 'Shouldnt be called' 
      .call (options, callback) ->
        callback null, true
      .call
        if: -> @status()
      , (options, callback) ->
        # Must be called
        next()
