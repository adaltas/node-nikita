
nikita = require '../../src'

describe 'action.scheduler', -> # Test on_call

  describe 'arguments', ->

    it 'function', ->
      nikita ->
        (await @call ->
          new Promise (resolve) -> resolve 1
        ).should.eql 1

    it 'array', ->
      (await nikita.call [
        -> new Promise (resolve) -> resolve 1
        -> new Promise (resolve) -> resolve 2
      ])
      .should.eql [1, 2]

  describe 'flow', ->

    it 'executed 1 args with 2 actions sequentially', ->
      stack = []
      nikita.call [
        handler: ->
          stack.push 1
          new Promise (resolve) ->
            setTimeout ->
              stack.push 2
              resolve 1
            , 100
      ,
        handler: ->
          stack.push 3
          new Promise (resolve) ->
            setTimeout ->
              stack.push 4
              resolve 2
            , 10
      ]
      .should.be.resolvedWith [1, 2]
      .then -> stack.should.eql [1, 2, 3, 4]

    it 'executed 2 actions sequentially', ->
      stack = []
      await nikita ({metadata}) ->
        stack.push 1
      .call ({metadata}) ->
        new Promise (resolve, reject) ->
          setTimeout ->
            stack.push 2
            resolve()
          , 100
      .call ({metadata}) ->
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
  
  describe 'error handling', ->

    it 'throw error and keep going', ->
      stack = []
      nikita ->
        # The following used to hang the scheduler
        @call (->)
        await new Promise (resolve, reject) ->
          setTimeout resolve, 10
        @call (->)

    it 'parent get the uncatched and last error', ->
      # Note, there was a bug where the last action was executed but the error
      # was swallowed
      nikita ->
        try
          await @call -> throw Error 'ok'
        catch err
        @call ->
          throw Error 'Catch me'
      .should.be.rejectedWith 'Catch me'
        
