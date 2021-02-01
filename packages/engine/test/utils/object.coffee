
{copy, diff, equals, filter} = require '../../src/utils/object'

describe 'utils.object', ->
  
  describe 'copy', ->
  
    it 'filter properties', ->
      copy {a: 'value 1', b: 'value 2', c: 1, d: 2}, ['a', 'c']
      .should.eql {a: 'value 1', c: 1}
        
    it 'is immutable', ->
      source = {a: 'value 1', b: 'value 2', c: 1, d: 2}
      copy source, ['a', 'c']
      source.should.eql {a: 'value 1', b: 'value 2', c: 1, d: 2}

  # describe 'equals', ->
  #   it 'two objects', ->
  #     equals({a: '1', b: '2'}, {a: '1', b: '2'}).should.be.true()
  #     equals({a: '1', b: '1'}, {a: '2', b: '2'}).should.be.false()
  #     equals({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.be.true()
  #     equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'c']).should.be.true()
  #     equals({a: '1', b: '-', c: '3'}, {a: '1', b: '+', c: '3'}, ['a', 'b']).should.be.false()

  describe 'diff', ->

    it 'two objects', ->
      diff({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}, ['a', 'c']).should.eql {}
      diff({a: '1', b: '21', c: '3'}, {a: '1', b: '22', c: '3'}, ['a', 'c']).should.eql {}
      diff({a: '11', b: '2', c: '3'}, {a: '12', b: '2', c: '3'}, ['a', 'c']).should.eql {'a': ['11', '12']}

    it 'two objects without keys', ->
      diff({a: '1', b: '2', c: '3'}, {a: '1', b: '2', c: '3'}).should.eql {}
      diff({a: '11', b: '2', c: '3'}, {a: '12', b: '2', c: '3'}).should.eql {'a': ['11', '12']}

  describe 'filter', ->
        
    it 'black list', ->
      filter a: 1, b: 2, c: 3, ['b']
      .should.eql a: 1, c: 3
    
    it 'white list', ->
      filter a: 1, b: 2, c: 3, null, ['b']
      .should.eql b: 2
        
    it 'black and white list', ->
      filter a: 1, b: 2, c: 3, ['b'], ['a', 'b']
      .should.eql a: 1
