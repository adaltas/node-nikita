
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'api status', ->

  describe 'sync', ->

    it 'default to false', ->
      nikita
      .call (options) ->
        return true
      .call ->
        @status().should.be.false()
      .promise()

    it 'set status to true', ->
      nikita
      .call (options) ->
        @call (_, callback) ->
          callback null, true
      .call ->
        @status().should.be.true()
      .promise()

    it 'set status to false', ->
      nikita
      .call (options) ->
        @call (_, callback) ->
          callback null, false
      .call ->
        @status().should.be.false()
      .promise()

    it 'catch error', ->
      nikita
      .call (options) ->
        throw Error 'Catchme'
      .then (err) ->
        err.message.should.eql 'Catchme'
      .promise()

  describe 'async', ->

    it 'set status to true', ->
      nikita
      .call (options, next) ->
        process.nextTick ->
          next null, true
      .call ->
        @status().should.be.true()
      .promise()

    it 'set status to false', ->
      nikita
      .call (options, next) ->
        process.nextTick ->
          next null, false
      .call ->
        @status().should.be.false()
      .promise()

    it 'set status to false while child module is true', ->
      n = nikita()
      n.call (options, callback) ->
        n.system.execute
          cmd: 'ls -l'
        , (err, executed, stdout, stderr) ->
          executed.should.be.true() unless err
          callback err, false
      n.call ->
        @status().should.be.false()
      n.promise()

    it 'set status to true while module sending is false', ->
      n = nikita()
      n.call (options, callback) ->
        n.system.execute
          cmd: 'ls -l'
          if: false
        , (err, executed, stdout, stderr) ->
          executed.should.be.false() unless err
          callback err, true
      n.call ->
        @status().should.be.true()
      n.promise()

  describe 'function', ->

    it 'get without arguments', ->
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
      .promise()

    it 'get current', ->
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
      .promise()

    it 'get previous', ->
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
      .promise()

    it 'get previous n', ->
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
      .promise()

    it 'report conditions', ->
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
      .call ->
        @status().should.be.false()
      .promise()

    it 'retrieve inside conditions', ->
      condition_called = false
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
        condition_called = true
        callback()
      .call ->
        throw Error 'Should be called' unless condition_called
      .promise()

    it 'set status to false', ->
      nikita
      .call (options, callback) ->
        callback null, true
      .call ->
        status = @status false
        status.should.be.true()
      .call ->
        @status().should.be.false()
      .promise()

    it 'set status to true', ->
      nikita
      .call (options, callback) ->
        callback null, false
      .call ->
        status = @status true
        status.should.be.false()
      .call ->
        @status().should.be.true()
      .promise()
