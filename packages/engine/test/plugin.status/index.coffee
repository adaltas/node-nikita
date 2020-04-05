
nikita = require '../../src'

describe 'plugin.status', ->
  
  describe 'returned coercion', ->

    it 'convert `true` to `{status: true}`', ->
      nikita.call -> true
      .should.be.resolvedWith status: true

    it 'convert `false` to `{status: false}`', ->
      nikita.call -> false
      .should.be.resolvedWith status: false

    it 'convert `{status: true}` to `{status: true}`', ->
      nikita.call -> status: true
      .should.be.resolvedWith status: true

    it 'convert `{status: false}` to `{status: false}`', ->
      nikita.call -> status: false
      .should.be.resolvedWith status: false
  
  describe 'option `raw`', ->
    
    it 'leave `true` as is', ->
      nikita.call raw: true, -> true
      .should.be.resolvedWith true
        
    it 'leave `false` as is', ->
      nikita.call raw: true, -> true
      .should.be.resolvedWith true

    it 'leave `{}` as is', ->
      nikita.call -> {}
      .should.be.resolvedWith {}
    
    
