
schedule = require '../../src/schedulers/native'

describe 'scheduler.flow', ->
  
  describe 'continue with try/catch', ->
  
    it 'rejected promise', ->
      stack = []
      scheduler = schedule()
      await scheduler.push -> new Promise (resolve) ->
        stack.push 1
        resolve 1
      try
        await scheduler.push -> new Promise (resolve, reject) ->
          stack.push 2
          reject Error 'catchme'
      catch err
        stack.push err.message
      await scheduler.push -> new Promise (resolve) ->
        stack.push 3
        resolve 3
      scheduler
      .should.be.resolved()
      .then -> stack.should.eql [1, 2, 'catchme', 3]
      
    it 'rejected promise in last child', ->
      stack = []
      scheduler = schedule()
      await scheduler.push -> new Promise (resolve) ->
        stack.push 1
        resolve 1
      try
        await scheduler.push -> new Promise (resolve, reject) ->
          stack.push 2
          reject Error 'catchme'
      catch err
        stack.push err.message
      scheduler
      .should.be.resolved()
      .then -> stack.should.eql [1, 2, 'catchme']
        
  describe 'interupted without try/catch', ->

    it 'push rejected promise', ->
      stack = []
      scheduler = schedule()
      scheduler.push -> new Promise (resolve) ->
        stack.push 1
        resolve 1
      scheduler.push -> new Promise (resolve, reject) ->
        stack.push 2
        reject Error 'catchme'
      scheduler.push -> new Promise (resolve) ->
        stack.push 3
        resolve 3
      scheduler
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1, 2]
    
    it 'push synchronously', ->
      stack = []
      scheduler = schedule()
      scheduler.push ->
        stack.push 1
        true
      scheduler.push ->
        stack.push 2
        throw Error 'catchme'
      scheduler.push ->
        stack.push 3
        true
      scheduler
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1, 2]

    it 'push array', ->
      stack = []
      scheduler = schedule()
      scheduler.push [
          ->
            stack.push 1
            new Promise (resolve, reject) -> resolve()
          ->
            stack.push 2
            new Promise (resolve, reject) -> reject Error 'catchme'
          ->
            stack.push 3
            new Promise (resolve, reject) -> resolve()
        ]
      .should.be.rejectedWith 'catchme'
      .then -> stack.should.eql [1, 2]
