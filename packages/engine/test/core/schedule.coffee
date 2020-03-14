
nikita = require '../../src'

describe 'core schedule', ->

  it 'executed sequentially', ->
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
    
