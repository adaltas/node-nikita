
nikita = require '../../src'
schedule = require '../../src/schedule'

describe 'core schedule', ->

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
  
  describe 'handler', ->
    
    it 'return a promise', ->
      scheduler = schedule()
      promises = Promise.all [
        scheduler.add -> new Promise (resolve) -> resolve 1
        scheduler.add -> new Promise (resolve) -> resolve 2
      ]
      scheduler.pump()
      promises.should.be.resolvedWith [1, 2]
        
    it 'return a function', ->
      scheduler = schedule()
      promises = Promise.all [
        scheduler.add -> [
          -> new Promise (resolve) -> resolve 1
          -> new Promise (resolve) -> resolve 2
        ]
        scheduler.add -> new Promise (resolve) -> resolve 3
      ]
      scheduler.pump()
      promises.should.be.resolvedWith [[1, 2], 3]
    
