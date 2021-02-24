
session = require '../../src/session'

describe 'session.creation', ->
  
  describe 'args is array of actions', ->
  
    it 'which succeed', ->
      result = await session [
          -> 1
          -> 2
        ]
      result.should.eql [1, 2]
    
    it 'first throw error', ->
      session [
          -> throw Error 'Catchme'
          -> true
        ]
      .should.be.rejectedWith 'Catchme'
