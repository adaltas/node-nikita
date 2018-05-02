
array = require '../../src/misc/array'
should = require 'should'
test = require '../test'

describe 'misc.array', ->

  scratch = test.scratch @

  it 'compare', ->
    array.compare(['a'], ['a']).should.be.true()
    array.compare(['a', 'b'], ['a', 'b']).should.be.true()
    array.compare(['a', 'b'], ['a']).should.be.false()
    array.compare(['a'], ['a', 'b']).should.be.false()

  it 'flatten', ->
    array.flatten([['a'], ['b']]).should.eql ['a', 'b']
    array.flatten([['a',['b']], [['c', ['d']]]]).should.eql ['a', 'b', 'c', 'd']
    array.flatten([['a',['b']], [['c', ['d']]], ['e']], -1).should.eql ['a', 'b', 'c', 'd', 'e']
    array.flatten([['a',['b']], [['c', ['d']]], ['e']], 0).should.eql ['a', ['b'], ['c', ['d']], 'e']
    array.flatten([['a',['b']], [['c', ['d']]], ['e']], 1).should.eql ['a', 'b', 'c', ['d'], 'e']

  it 'intersect', ->
    array.intersect(['a', 'c', 'd'], ['e', 'd', 'c']).should.eql ['c', 'd']
    array.intersect(['a', 'c', 'd'], []).should.eql []
    array.intersect([], ['e', 'd', 'c']).should.eql []

  it 'merge', ->
    array.merge(['a', 'b'], ['c', 'a']).should.eql ['a', 'b', 'c', 'a']

  it 'unique', ->
    array.unique(['a', 'b', 'c', 'a']).should.eql ['a', 'b', 'c']
