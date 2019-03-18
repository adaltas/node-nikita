
nikita = require '../../../src'
{tags, scratch} = require '../../test'
# TODO: usage of scratch dir is irrelevant for this test, should be removed

return unless tags.api

describe 'api call sync', ->

  describe 'sync', ->

    it 'execute a handler', ->
      called = 0
      touched = 0
      nikita
      .file.touch
        target: "#{scratch}/file_a"
      , (err) ->
        touched++
      .call ->
        called++
      .file.touch
        target: "#{scratch}/file_b"
      , (err) ->
        touched++
      .call ->
        called.should.eql 1
        touched.should.eql 2
      .promise()

    it 'execute a callback', ->
      called = 0
      nikita
      # 1st arg options with handler, 2nd arg a callback
      .call handler: (->), (err, {status}) ->
        status.should.be.false() unless err
        called++ unless err
      # 1st arg handler, 2nd arg a callback
      .call (->), (err, {status}) ->
        status.should.be.false() unless err
        called++ unless err
      .call ->
        called.should.eql 2
      .promise()

    it 'pass options', ->
      nikita
      .call test: true, ({options}) ->
        options.test.should.be.true()
      .promise()

    it 'pass multiple options', ->
      nikita
      .call {test1: true}, {test2: true}, ({options}) ->
        options.test1.should.be.true()
        options.test2.should.be.true()
      .promise()

    it 'handler is called only once', ->
      counts = a: 0, b: 0, c: 0
      nikita
      .system.remove target: "#{scratch}"
      .call ({}) ->
        counts.a++
        @call ({}) ->
          counts.b++
          @call ({}) ->
            counts.c++
      .next (err) ->
        throw err if err
        counts.a.should.eql 1
        counts.b.should.eql 1
        counts.c.should.eql 1
      .promise()
