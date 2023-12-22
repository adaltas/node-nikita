
import each from 'each'
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'session.scheduler.flow', ->
  return unless test.tags.api

  describe 'scheduler:args', ->

    it 'executed 1 args with 2 actions sequentially', ->
      stack = []
      nikita.call [
        ->
          stack.push 1
          new Promise (resolve) ->
            setTimeout ->
              stack.push 2
              resolve 1
            , 100
        ->
          stack.push 3
          new Promise (resolve) ->
            setTimeout ->
              stack.push 4
              resolve 2
            , 10
      ]
      .should.be.resolvedWith [1, 2]
      .then -> stack.should.eql [1, 2, 3, 4]

  describe 'scheduler:in', ->

    it 'concurrency is parallel', ->
      history = []
      await nikita ->
        await each Array.from({length: 3}), true, (_, i) =>
          @call ->
            new Promise (resolve) ->
              history.push "#{i}:start"
              setImmediate ->
                history.push "#{i}:end"
                resolve()
      history.should.eql [
        '0:start', '1:start', '2:start'
        '0:end', '1:end', '2:end'
      ]

    it 'await between children', ->
      stack = []
      nikita ->
        # The following used to hang the scheduler
        @call (->)
        await new Promise (resolve, reject) ->
          setTimeout resolve, 10
        @call (->)

    they 'with try/finally', ({ssh}) ->
      stack = []
      await nikita
        $ssh: ssh
      , ->
        try
          @call ({ssh}) -> 'getme'
        finally
          @call ({ssh}) -> 'finally'
      .then (result) -> result.should.eql 'getme'

  describe 'scheduler:in_fluent', ->

    it 'fluent is always sequential', ->
      history = []
      handler = (name) ->
        name: name
        $handler: ({metadata: {position}}) ->
          history.push "#{name}:start"
          new Promise (resolve) ->
            setTimeout ->
              history.push "#{name}:end"
              resolve()
            , 50
      await nikita ->
        @call handler "before:1"
        @call handler "before:2"
        @call handler "before:3"
        @
          .call handler "fluent:1"
          .call handler "fluent:2"
          .call handler "fluent:3"
        @call handler "after:1"
        @call handler "after:2"
        @call handler "after:3"
        true
      # Note, fluent:1 cannot start after before:3 ends because at that time, we
      # have no information about the usage being fluent
      history.should.eql [
        'before:1:start'
        'before:2:start'
        'before:3:start'
        'fluent:1:start'
        'before:1:end'
        'before:2:end'
        'before:3:end'
        'fluent:1:end'
        'fluent:2:start'
        'fluent:2:end'
        'fluent:3:start'
        'fluent:3:end'
        'after:1:start'
        'after:2:start'
        'after:3:start'
        'after:1:end'
        'after:2:end'
        'after:3:end'
      ]

  describe 'scheduler:out', ->

    it 'with in action and 2 out child actions sequentially', ->
      stack = []
      await nikita () ->
        stack.push 1
      .call () ->
        new Promise (resolve, reject) ->
          setTimeout ->
            stack.push 2
            resolve()
          , 100
      .call () ->
        new Promise (resolve, reject) ->
          stack.push 3
          resolve()
      stack.should.eql [1,2,3]

    it 'await root return value once children are processed', ->
      app = nikita ({metadata}) ->
        "value @ #{metadata.depth}"
      app.call ({metadata}) ->
        new Promise (resolve, reject) ->
          setTimeout resolve, 100
      app.call ({metadata}) ->
        new Promise (resolve, reject) ->
          resolve()
      result = await app
      result.should.eql 'value @ 0'

  describe 'scheduler:in&out', ->

    it 'with in action containing children and 2 out child actions sequentially', ->
      stack = []
      n = nikita () ->
        await @call () ->
          new Promise (resolve, reject) ->
            setTimeout ->
              stack.push 1
              resolve()
            , 100
        await @call () ->
          new Promise (resolve, reject) ->
            setTimeout ->
              stack.push 2
              resolve()
            , 100
      n.call () ->
        new Promise (resolve, reject) ->
          setTimeout ->
            stack.push 3
            resolve()
          , 100
      n.call () ->
        new Promise (resolve, reject) ->
          stack.push 4
          resolve()
      await n
      stack.should.eql [1,2,3,4]
