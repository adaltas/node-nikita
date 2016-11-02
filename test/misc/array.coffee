
array = require '../../src/misc/array'
should = require 'should'
test = require '../test'

describe 'misc.array', ->

  scratch = test.scratch @

  describe 'compare', ->
    
    it 'validate', ->
      array.compare(['a'], ['a']).should.be.true()
      array.compare(['a', 'b'], ['a', 'b']).should.be.true()
      array.compare(['a', 'b'], ['a']).should.be.false()
      array.compare(['a'], ['a', 'b']).should.be.false()
