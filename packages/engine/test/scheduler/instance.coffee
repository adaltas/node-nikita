
schedule = require '../../src/schedulers/native'

describe 'scheduler.instance', ->
  
  it 'is a promise', ->
    schedule()
    .should.be.a.Promise()
      
  it 'resolve', ->
    new Promise (resolve, reject) ->
      scheduler = schedule()
      scheduler.push [
        -> new Promise (accept) -> setImmediate accept 1
        -> new Promise (accept) -> accept 2
      ]
      scheduler.push -> new Promise (accept) ->  accept 3
      scheduler.then resolve, reject
