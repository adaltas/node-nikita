
schedule = require '../../src/schedulers/native'

describe 'scheduler.instance', ->
  
  it 'is a promise', ->
    schedule()
    .should.be.a.Promise()
      
  it 'accept handlers in its arguments', ->
    schedule([
      -> new Promise (accept) -> setImmediate accept 1
      -> new Promise (accept) -> accept 2
    ])
    .should.be.resolvedWith [1, 2]
      
  it 'catch error', ->
    # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all
    # It rejects immediately upon any of the input promises rejecting or
    # non-promises throwing an error, and will reject with this first rejection
    # message / error.
    # Promise.all([
    #   new Promise (accept) -> setTimeout (-> accept 1), 100
    #   new Promise (accept, reject) -> reject Error 'catchme'
    #   new Promise (accept) -> setTimeout (-> accept 1), 100
    # ]).should.be.rejectedWith 'catchme'
    schedule([
      -> new Promise (accept) -> setImmediate accept 1
      -> new Promise (accept, reject) -> reject Error 'catchme'
      -> new Promise (accept) -> setImmediate accept 2
    ])
    .should.be.rejectedWith 'catchme'
      
  it 'resolve', ->
    new Promise (resolve, reject) ->
      scheduler = schedule()
      scheduler.push [
        -> new Promise (accept) -> setImmediate accept 1
        -> new Promise (accept) -> accept 2
      ]
      scheduler.push -> new Promise (accept) ->  accept 3
      scheduler.then resolve, reject
