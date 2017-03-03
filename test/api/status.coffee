
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api status', ->

  describe 'sync', ->

    it 'default to false', (next) ->
      nikita
      .call (options) ->
        return true
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'set status to true', (next) ->
      nikita
      .call (options) ->
        @call (_, callback) ->
          callback null, true
      .then (err, status) ->
        status.should.be.true()
        next()

    it 'set status to false', (next) ->
      nikita
      .call (options) ->
        @call (_, callback) ->
          callback null, false
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'catch error', (next) ->
      nikita
      .call (options) ->
        throw Error 'Catchme'
      .then (err, status) ->
        err.message.should.eql 'Catchme'
        next()

  describe 'async', ->

    it 'set status to true', (next) ->
      nikita
      .call (options, next) ->
        process.nextTick ->
          next null, true
      .then (err, status) ->
        status.should.be.true() unless err
        next err

    it 'set status to false', (next) ->
      nikita
      .call (options, next) ->
        process.nextTick ->
          next null, false
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'set status to false while child module is true', (next) ->
      m = nikita()
      .call (options, callback) ->
        m.system.execute
          cmd: 'ls -l'
        , (err, executed, stdout, stderr) ->
          executed.should.be.true() unless err
          callback err, false
      .then (err, status) ->
        status.should.be.false()
        next()

    it 'set status to true while module sending is false', (next) ->
      m = nikita()
      .call (options, callback) ->
        m.system.execute
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
      nikita
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
      nikita
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
      nikita
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
      nikita
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
      nikita
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
      nikita
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

    it 'set status to false', (next) ->
      nikita
      .call (options, callback) ->
        callback null, true
      .call ->
        status = @status false
        status.should.be.true()
      .call ->
        @status().should.be.false()
      .then next

    it 'set status to true', (next) ->
      nikita
      .call (options, callback) ->
        callback null, false
      .call ->
        status = @status true
        status.should.be.false()
      .call ->
        @status().should.be.true()
      .then next
