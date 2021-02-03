
error = require '../../src/utils/error'

describe 'utils.error', ->
  
  it 'accept a code and an array message', ->
    (->
      throw error 'AN_ERROR', ['this is', 'an error']
    ).should.throw
      message: 'AN_ERROR: this is an error'
      code: 'AN_ERROR'
        
  it 'skip undefined lines in message', ->
    (->
      throw error 'AN_ERROR', ['this is', undefined, 'an error']
    ).should.throw 'AN_ERROR: this is an error'
