
misc = require "../src/misc"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'misc', ->

  scratch = test.scratch @

  describe 'array', ->

    it 'intersect', ->
      misc.array.intersect(['a', 'c', 'd'], ['e', 'd', 'c']).should.eql ['c', 'd']
      misc.array.intersect(['a', 'c', 'd'], []).should.eql []
      misc.array.intersect([], ['e', 'd', 'c']).should.eql []

    it 'unique', ->
      misc.array.unique(['a', 'b', 'c', 'a']).should.eql ['a', 'b', 'c']

    it 'merge', ->
      misc.array.merge(['a', 'b'], ['c', 'a']).should.eql ['a', 'b', 'c', 'a']

  describe 'object', ->

    describe 'equals', ->

      it 'two objects', ->
        misc.object.equals({a: '1', b: '2'}, {a: '1', b: '2'}).should.be.true
        misc.object.equals({a: '1', b: '1'}, {a: '2', b: '2'}).should.be.false
        misc.object.equals({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.be.true
        misc.object.equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'c']).should.be.true
        misc.object.equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'b']).should.be.false

    describe 'diff', ->

      it 'two objects', ->
        misc.object.diff({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.eql {}
        misc.object.diff({a: '1', b: '21', c: '3'}, {a: '1', b: '22', c: '3'}, ['a', 'c']).should.eql {}
        misc.object.diff({a: '11', b: '2', c: '3'}, {a: '12', b: '2', c: '3'}, ['a', 'c']).should.eql {'a': ['11', '12']}

      it 'two objects without keys', ->
        misc.object.diff({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}).should.eql {}
        misc.object.diff({a: '11', b: '2', c: '3'}, {a: '12', b: '2', c: '3'}).should.eql {'a': ['11', '12']}







