
schedule = require '../../src/schedulers/native'

describe 'scheduler', ->

  describe 'push return', ->

    it 'function return a promise', ->
      scheduler = schedule()
      scheduler.push (->)
      .should.be.a.Promise()

    it 'array return a promise', ->
      scheduler = schedule()
      scheduler.push [ (->) ]
      .should.be.a.Promise()

  describe 'push parallel error', ->

    it 'function', ->
      scheduler = schedule()
      (await Promise.allSettled [
        scheduler.push -> new Promise (accept, reject) -> reject Error 1
        scheduler.push -> new Promise (accept, reject) -> reject Error 2
      ])
      .map (e) -> e.reason.message
      .should.eql ['1', '2']

    it 'an array', ->
      scheduler = schedule()
      (await Promise.allSettled [
        scheduler.push [
          -> new Promise (accept, reject) -> reject Error 1
          -> new Promise (accept, reject) -> reject Error 2
        ]
        scheduler.push [
          -> new Promise (accept, reject) -> accept 3
          -> new Promise (accept, reject) -> reject Error 4
        ]
      ])
      .map (e) -> e.reason.message
      .should.eql ['1', '4']

    it 'function returning an array', ->
      scheduler = schedule()
      (await Promise.allSettled [
        scheduler.push -> [
          -> new Promise (accept, reject) -> reject Error 1
          -> new Promise (accept, reject) -> reject Error 2
        ]
        scheduler.push -> [
          -> new Promise (accept, reject) -> accept 3
          -> new Promise (accept, reject) -> reject Error 4
        ]
      ])
      .map (e) -> e.reason.message
      .should.eql ['1', '4']

  describe 'push parallel sync', ->

    it 'function', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push -> new Promise (accept) -> accept 1
          scheduler.push -> new Promise (accept) -> accept 2
        ]
      .should.be.resolvedWith [1, 2]

    it 'an array', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push [
            -> new Promise (accept) -> accept 1
            -> new Promise (accept) -> accept 2
          ]
          scheduler.push [
            -> new Promise (accept) -> accept 3
            -> new Promise (accept) -> accept 4
          ]
        ]
      .should.be.resolvedWith [[1, 2], [3, 4]]

    it 'function returning an array', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push -> [
            -> new Promise (accept) -> accept 1
            -> new Promise (accept) -> accept 2
          ]
          scheduler.push -> [
            -> new Promise (accept) -> accept 3
            -> new Promise (accept) -> accept 4
          ]
        ]
      .should.be.resolvedWith [[1, 2], [3, 4]]

  describe 'push parallel async', ->

    it 'function', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push -> new Promise (accept) -> setTimeout (-> accept 1), 50
          scheduler.push -> new Promise (accept) -> setTimeout (-> accept 2), 100
          scheduler.push -> new Promise (accept) -> setTimeout (-> accept 3), 50
        ]
      .should.be.resolvedWith [1, 2, 3]

    it 'an array', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push [
            -> new Promise (accept) -> setTimeout (-> accept 1), 50
            -> new Promise (accept) -> setTimeout (-> accept 2), 100
            -> new Promise (accept) -> setTimeout (-> accept 3), 50
          ]
          scheduler.push [
            -> new Promise (accept) -> setTimeout (-> accept 4), 50
            -> new Promise (accept) -> setTimeout (-> accept 5), 100
            -> new Promise (accept) -> setTimeout (-> accept 6), 50
          ]
        ]
      .should.be.resolvedWith [[1, 2, 3], [4, 5, 6]]

    it 'function returning an array', ->
      scheduler = schedule()
      Promise.all [
          scheduler.push -> [
            -> new Promise (accept) -> setTimeout (-> accept 1), 50
            -> new Promise (accept) -> setTimeout (-> accept 2), 100
            -> new Promise (accept) -> setTimeout (-> accept 3), 50
          ]
          scheduler.push -> [
            -> new Promise (accept) -> setTimeout (-> accept 4), 50
            -> new Promise (accept) -> setTimeout (-> accept 5), 100
            -> new Promise (accept) -> setTimeout (-> accept 6), 50
          ]
        ]
      .should.be.resolvedWith [[1, 2, 3], [4, 5, 6]]
    
