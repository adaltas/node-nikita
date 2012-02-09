
assert = require 'assert'
misc = require '../lib/misc'

module.exports =
    'merge # enrich': (next) ->
        obj1 = { a_key: 'a value', b_key: 'b value'}
        obj2 = { b_key: 'new b value'}
        result = misc.merge obj1, obj2
        assert.eql result, obj1
        assert.eql obj1.b_key, 'new b value'
        next()
    'merge # create': (next) ->
        obj1 = { a_key: 'a value', b_key: 'b value'}
        obj2 = { b_key: 'new b value'}
        result = misc.merge {}, obj1, obj2
        assert.eql result.b_key, 'new b value'
        next()
    'merge # array': (next) ->
        obj1 = { a_key: 'a value', b_key: ['b value']}
        obj2 = { b_key: ['new b value']}
        misc.merge obj1, obj2
        assert.eql obj1.b_key, ['new b value']
        next()
    'merge # inverse': (next) ->
        obj1 = { b_key: 'b value'}
        obj2 = { a_key: 'a value', b_key: 'new b value'}
        misc.merge true, obj1, obj2
        assert.eql obj1.a_key, 'a value'
        assert.eql obj1.b_key, 'b value'
        next()
    'merge # same object': (next) ->
        obj1 = { a_key: { b_key : 'b value' } }
        obj2 = obj1
        misc.merge true, obj1, obj2
        assert.eql obj1.a_key.b_key, 'b value'
        next()
