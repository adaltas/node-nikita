
schedule = require '../../src/schedulers/native'

describe 'scheduler.flow', ->
  
  it 'pause in options', ->
    stack = []
    scheduler = schedule null, pause: true
    prom1 = scheduler.push -> new Promise (resolve) ->
      stack.push 1
      resolve 1
    prom1 = scheduler.push -> new Promise (resolve) ->
      stack.push 2
      resolve 2
    setTimeout ->
      scheduler.state.stack.length.should.eql 2
      scheduler.resume()
    , 50
    scheduler
  
  it 'pause as a function', ->
    stack = []
    scheduler = schedule null
    prom1 = scheduler.push -> new Promise (resolve) ->
      stack.push 1
      resolve 1
    scheduler.pause()
    prom1 = scheduler.push -> new Promise (resolve) ->
      stack.push 2
      resolve 2
    setTimeout ->
      scheduler.state.stack.length.should.eql 1
      scheduler.resume()
    , 50
    scheduler
