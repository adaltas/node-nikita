
nikita = require '../../src'
{tags} = require '../test'
  
return unless tags.api

describe 'api status', ->

  describe 'sync', ->

    it 'default to false', ->
      nikita
      .call ->
        return true
      .call ->
        @status().should.be.false()
      .promise()

    it 'set status to true', ->
      nikita
      .call ->
        @call (_, callback) ->
          callback null, true
      .call ->
        @status().should.be.true()
      .promise()

    it 'set status to false', ->
      nikita
      .call ->
        @call (_, callback) ->
          callback null, false
      .call ->
        @status().should.be.false()
      .promise()

    it 'catch error', ->
      nikita
      .call ->
        throw Error 'Catchme'
      .next (err) ->
        err.message.should.eql 'Catchme'
      .promise()

  describe 'async', ->

    it 'set status to true', ->
      nikita
      .call ({}, next) ->
        process.nextTick ->
          next null, true
      .call ->
        @status().should.be.true()
      .promise()

    it 'set status to false', ->
      nikita
      .call ({}, next) ->
        process.nextTick ->
          next null, false
      .call ->
        @status().should.be.false()
      .promise()

    it 'set status to false while child module is true', ->
      n = nikita()
      n.call ({}, callback) ->
        n.system.execute
          cmd: 'ls -l'
        , (err, {status}) ->
          status.should.be.true() unless err
          callback err, false
      n.call ->
        @status().should.be.false()
      n.promise()

    it 'set status to true while module sending is false', ->
      n = nikita()
      n.call ({}, callback) ->
        n.system.execute
          cmd: 'ls -l'
          if: false
        , (err, {status}) ->
          status.should.be.false() unless err
          callback err, true
      n.call ->
        @status().should.be.true()
      n.promise()

  describe 'function', ->

    it 'get without arguments', ->
      nikita
      .call ({}, callback) ->
        @status().should.be.false()
        callback null, false
      , (err, status) ->
        @status().should.be.false()
      .call ({}, callback) ->
        @status().should.be.false()
        callback null, true
      .call ({}, callback) ->
        @status().should.be.true()
        callback null, false
      .call ({}, callback) ->
        @status().should.be.true()
        callback null, false
      .promise()

    it 'get asc 0', ->
      nikita
      .call ->
        (@status(0) is undefined).should.be.true()
      , (err) ->
        @status(0).should.be.false()
      .call ->
        @call ({}, callback) ->
          callback null, true
      , (err) ->
        @status(0).should.be.true()
      .call ({}, callback) ->
        callback null, false
      , (err) ->
        @status(0).should.be.false()
      .call ({}, callback) ->
        callback null, true
      , (err) ->
        @status(0).should.be.true()
      .promise()

    it 'get desc n-1', ->
      nikita
      .call ->
        (@status(-1) is undefined).should.be.true()
      .call ->
        @status(-1).should.be.false()
      , (err) ->
        @status(-1).should.be.false()
      .call ({}, callback) ->
        callback null, true
      , (err, status) ->
        @status(-1).should.be.false()
      .call ->
        @status(-1).should.be.true()
      .promise()

    it 'get desc n-2', ->
      nikita
      .call (->)
      .call ->
        (@status(-2) is undefined).should.be.true()
      .call ->
        @status(-2).should.be.false()
      , (err) ->
        @status(-2).should.be.false()
      .call ({}, callback) ->
        callback null, true
      .call ->
        @status(-2).should.be.false()
      .call ->
        @status(-2).should.be.true()
      .promise()

    it 'report conditions', ->
      nikita
      .call
        if: -> true
      , ({}, callback) ->
        callback null, true
      .next (err, {status}) ->
        status.should.be.true() unless err
      .call
        if: -> false
      , ({}, callback) ->
        callback null, true
      .call ->
        @status().should.be.false()
      .promise()

    it 'retrieve inside conditions', ->
      condition_called = false
      nikita
      .call
        if: -> @status()
      , ({}, callback) ->
        callback Error 'Shouldnt be called'
      .call ({}, callback) ->
        callback null, true
      .call
        if: -> @status()
      , ({}, callback) ->
        condition_called = true
        callback()
      .call ->
        throw Error 'Should be called' unless condition_called
      .promise()

    it 'set status to false', ->
      nikita
      .call ({}, callback) ->
        callback null, true
      .call ->
        status = @status false
        status.should.be.true()
      .call ->
        @status().should.be.false()
      .promise()

    it 'set status to true', ->
      nikita
      .call ({}, callback) ->
        callback null, false
      .call ->
        status = @status true
        status.should.be.false()
      .call ->
        @status().should.be.true()
      .promise()

    it.skip 'set status when sync is called in async', ->
      console.log '---------'
      nikita
      .call ({}, callback) ->
        @call ->
          console.log '1 - first callback', @status()
          callback null, true
      # , (err, {status}) ->
      #   console.log 'callback', status
      # .call ({}, callback) ->
      #   @call ->
      #     callback null, false
      .call
        if: -> console.log '2 - second if condition', @status()
      , ->
        console.log '3 - second callback', @status()
      .promise()
