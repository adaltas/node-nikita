
import promise from '@nikitajs/utils/promise'
import test from '../test.coffee'

describe 'utils.promise', ->
  return unless test.tags.api
  
  describe 'array_filter', ->
    
    it 'filter in sequentially', ->
      stack = []
      result = await promise.array_filter [1,2,3,4], 1, (el) ->
        new Promise (resolve) ->
          stack.push "#{el}:start"
          setTimeout ->
            stack.push "#{el}:end"
            resolve el % 2 is 0
          , (4 - el) * 100
      result.should.eql [2, 4]
      stack.should.eql [
        '1:start', '1:end',
        '2:start', '2:end',
        '3:start', '3:end',
        '4:start', '4:end'
      ]
    
    it 'filter in parallel', ->
      stack = []
      result = await promise.array_filter [1,2,3,4], -1, (el) ->
        new Promise (resolve) ->
          stack.push "#{el}:start"
          setTimeout ->
            stack.push "#{el}:end"
            resolve el % 2 is 0
          , (4 - el) * 100
      result.should.eql [2, 4]
      stack.should.eql [
        '1:start', '2:start',
        '3:start', '4:start',
        '4:end',   '3:end',
        '2:end',   '1:end'
      ]
  
  describe 'is', ->

    it 'true', ->
      promise.is(new Promise (->)).should.be.true()

    it 'false', ->
      promise.is({}).should.be.false()
