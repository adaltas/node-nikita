
misc = require '../../src/misc'
{tags} = require '../test'

return unless tags.api

describe 'merge', ->

  it 'enrich 1st object', ->
    obj1 = { a_key: 'a value', b_key: 'b value'}
    obj2 = { b_key: 'new b value'}
    result = misc.merge obj1, obj2
    result.should.eql obj1
    obj1.b_key.should.eql 'new b value'

  it 'create a new object if first arg is an empty object', ->
    obj1 = { a_key: 'a value', b_key: 'b value'}
    obj2 = { b_key: 'new b value'}
    result = misc.merge {}, obj1, obj2
    result.b_key.should.eql 'new b value'

  it 'create a new object if first arg is null', ->
    obj1 = { a_key: 'a value', b_key: 'b value'}
    obj2 = { b_key: 'new b value'}
    result = misc.merge null, obj1, obj2
    result.b_key.should.eql 'new b value'

  it 'overwrite arrays', ->
    obj1 = { a_key: 'a value', b_key: ['b value']}
    obj2 = { b_key: ['new b value']}
    misc.merge obj1, obj2
    obj1.b_key.should.eql ['new b value']

  it 'give priority to the last objects', ->
    obj1 = { b_key: 'b value'}
    obj2 = { a_key: 'a value', b_key: 'new b value'}
    misc.merge true, obj1, obj2
    obj1.a_key.should.eql 'a value'
    obj1.b_key.should.eql 'b value'

  it 'avoid infinite loop', ->
    obj1 = { a_key: { b_key : 'b value' } }
    obj2 = obj1
    misc.merge true, obj1, obj2
    obj1.a_key.b_key.should.eql 'b value'

  it 'overwrite regexp value', ->
    obj1 = { reg_key: /.*/mg, a_key: { regkey_key : /.*/ } }
    obj2 = { a_key: { regkey_key : /^.*$/ } }
    res = misc.merge {}, obj1, obj2
    res.should.eql { reg_key: /.*/mg, a_key: { regkey_key : /^.*$/ } }

  it 'overwrite buffer value', ->
    obj1 = { a_key: Buffer.from 'abc' }
    obj2 = { a_key: Buffer.from 'def' }
    res = misc.merge {}, obj1, obj2
    res.a_key.toString().should.eql 'def'
