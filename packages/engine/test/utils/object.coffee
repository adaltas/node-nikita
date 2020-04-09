
{copy} = require '../../src/utils/object'

describe 'utils.object', ->
  
  describe 'copy', ->
  
    it 'filter properties', ->
      copy {a: 'value 1', b: 'value 2', c: 1, d: 2}, ['a', 'c']
      .should.eql {a: 'value 1', c: 1}
        
    it 'is immutable', ->
      source = {a: 'value 1', b: 'value 2', c: 1, d: 2}
      copy source, ['a', 'c']
      source.should.eql {a: 'value 1', b: 'value 2', c: 1, d: 2}
