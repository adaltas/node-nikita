
{tags} = require '../../test'
nikita = require '../../../lib'

describe 'session.scheduler.flow', ->
  return unless tags.api

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

  it 'with in action containing children and 2 out child actions sequentially', ->
    stack = []
    n = nikita () ->
      @call () ->
        new Promise (resolve, reject) ->
          setTimeout ->
            stack.push 1
            resolve()
          , 100
      @call () ->
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
