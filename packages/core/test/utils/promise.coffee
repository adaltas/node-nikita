
import promise from '@nikitajs/core/utils/promise'
import test from '../test.coffee'

describe 'utils.promise', ->
  return unless test.tags.api
  
  describe 'array_filter', ->
    
    it 'filter', ->
      result = await promise.array_filter [1,2,3,4], (el) ->
        new Promise (resolve) ->
          setImmediate -> resolve el % 2 is 0
      result.should.eql [2, 4]
  
  describe 'is', ->

    it 'true', ->
      promise.is(new Promise (->)).should.be.true()

    it 'false', ->
      promise.is({}).should.be.false()
