
nikita = require '../../src'
schedule = require '../../src/schedule'

describe 'scheduler.add handler', ->

  it 'return a promise', ->
    scheduler = schedule()
    promises = Promise.all [
      scheduler.add -> new Promise (resolve) -> resolve 1
      scheduler.add -> new Promise (resolve) -> resolve 2
    ]
    scheduler.pump()
    promises.should.be.resolvedWith [1, 2]
      
  it 'return an array of functions', ->
    scheduler = schedule()
    promises = Promise.all [
      scheduler.add -> [
        -> new Promise (resolve) -> setTimeout (-> resolve 1), 100
        -> new Promise (resolve) -> setTimeout (-> resolve 2), 50
      ]
      scheduler.add -> new Promise (resolve) -> resolve 3
    ]
    scheduler.pump()
    promises.should.be.resolvedWith [[1, 2], 3]
      
