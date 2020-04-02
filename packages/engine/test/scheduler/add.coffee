
nikita = require '../../src'
schedule = require '../../src/schedule'

describe 'scheduler.add', ->
  
  it 'add array of handlers', (next) ->
    stack = []
    scheduler = schedule()
    scheduler.add [
      -> new Promise (resolve, reject) ->
        stack.push 1
        setTimeout (-> stack.push 2; resolve 1), 100
        
    ,
      -> new Promise (resolve, reject) ->
        stack.push 3
        setTimeout (-> stack.push 4; resolve 2), 50
    ]
    scheduler.on_end ->
      stack.should.eql [1, 2, 3, 4]
      next()

  it 'option first', (next) ->
    stack = []
    scheduler = schedule()
    scheduler.add ->
      new Promise (resolve, reject) ->
        stack.push 2
        resolve()
    scheduler.add ->
      new Promise (resolve, reject) ->
        stack.push 3
        resolve()
    scheduler.add ->
      new Promise (resolve, reject) ->
        stack.push 1
        resolve()
    , first: true
    scheduler.on_end ->
      stack.should.eql [1, 2, 3]
      next()
      
