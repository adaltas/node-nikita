
nikita = require '../../../src'
{tags, scratch} = require '../../test'

return unless tags.api

describe 'api call async', ->

  describe 'async', ->

    it 'execute a handler', ->
      called = 0
      touched = 0
      nikita
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call ({}, next) ->
        process.nextTick ->
          called++
          next()
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call ->
        called.should.eql 1
        touched.should.eql 2
      .promise()

    it 'execute a callback', ->
      called = 0
      touched = 0
      nikita
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call ({}, next) ->
        process.nextTick ->
          next()
      , (err) ->
        called++ unless err
      .file.touch
        target: "#{scratch}/a_file"
      , (err) ->
        touched++
      .call ->
        called.should.eql 1
        touched.should.eql 2
      .promise()

    it 'pass options', ->
      nikita
      .call test: true, ({options}, next) ->
        options.test.should.be.true()
        next()
      .promise()

    it 'pass multiple options', ->
      nikita
      .call {test1: true}, {test2: true}, ({options}, next) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
        next()
      .promise()

  describe 'async nested', ->

    it 'in a user callback', ->
      nikita
      .call ({}, next) ->
        @file
          target: "#{scratch}/a_file"
          content: 'ok'
        , next
      .assert
        status: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'ok'
      .promise()

    it 'in then with changes', ->
      nikita
      .call ({}, next) ->
        @file
          content: 'ok'
          target: "#{scratch}/a_file"
        .next next
      .assert
        status: true
      .file.assert
        target: "#{scratch}/a_file"
        content: 'ok'
      .promise()

    it 'in then without changes', ->
      nikita
      .call ({}, next) ->
        @file
          content: 'ok'
          target: "#{scratch}/a_file"
          if_exists: "#{scratch}/a_file"
        .next next
      .assert
        status: false
      .promise()

    it 'pass user arguments', ->
      callback_called = false
      nikita
      .call ({}, next) ->
        setImmediate ->
          next null, status: true, argument: 'argument'
      , (err, {status, argument}) ->
        callback_called = true
        status.should.be.true()
        argument.should.equal 'argument'
      .assert
        status: true
      .call ->
        callback_called.should.be.true()
      .promise()
