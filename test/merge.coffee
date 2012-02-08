
assert = require 'assert'
mecano = require '../'

module.exports =
    'enrich': (next) ->
        obj1 = { a_key: 'a value', b_key: 'b value'}
        obj2 = { b_key: 'new b value'}
        result = mecano.merge obj1, obj2
        assert.eql result, obj1
        assert.eql obj1.b_key, 'new b value'
        next()
    'create': (next) ->
        obj1 = { a_key: 'a value', b_key: 'b value'}
        obj2 = { b_key: 'new b value'}
        result = mecano.merge {}, obj1, obj2
        assert.eql result.b_key, 'new b value'
        next()
    'array': (next) ->
        obj1 = { a_key: 'a value', b_key: ['b value']}
        obj2 = { b_key: ['new b value']}
        mecano.merge obj1, obj2
        assert.eql obj1.b_key, ['new b value']
        next()
    'inverse': (next) ->
        obj1 = { b_key: 'b value'}
        obj2 = { a_key: 'a value', b_key: 'new b value'}
        mecano.merge true, obj1, obj2
        assert.eql obj1.a_key, 'a value'
        assert.eql obj1.b_key, 'b value'
        next()
    'same object': (next) ->
        obj1 = { a_key: { b_key : 'b value' } }
        obj2 = obj1
        mecano.merge true, obj1, obj2
        assert.eql obj1.a_key.b_key, 'b value'
        next()
