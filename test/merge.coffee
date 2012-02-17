
should = require 'should'
misc = require '../lib/misc'

describe 'merge', ->

    it 'should enrich 1st object', ->
        obj1 = { a_key: 'a value', b_key: 'b value'}
        obj2 = { b_key: 'new b value'}
        result = misc.merge obj1, obj2
        result.should.eql obj1
        obj1.b_key.should.eql 'new b value'

    it 'should create a new object', ->
        obj1 = { a_key: 'a value', b_key: 'b value'}
        obj2 = { b_key: 'new b value'}
        result = misc.merge {}, obj1, obj2
        result.b_key.should.eql 'new b value'

    it 'should overwrite arrays', ->
        obj1 = { a_key: 'a value', b_key: ['b value']}
        obj2 = { b_key: ['new b value']}
        misc.merge obj1, obj2
        obj1.b_key.should.eql ['new b value']

    it 'should give priority to the last objects', ->
        obj1 = { b_key: 'b value'}
        obj2 = { a_key: 'a value', b_key: 'new b value'}
        misc.merge true, obj1, obj2
        obj1.a_key.should.eql 'a value'
        obj1.b_key.should.eql 'b value'

    it 'should avoid infinite loop', ->
        obj1 = { a_key: { b_key : 'b value' } }
        obj2 = obj1
        misc.merge true, obj1, obj2
        obj1.a_key.b_key.should.eql 'b value'

