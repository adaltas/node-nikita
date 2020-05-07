
nikita = require '../../src'

describe 'plugins.status', ->
  
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
        
  describe 'last child no interference', ->

    it '`true` when child return `true`', ->
      nikita.call ({context}) ->
        @call -> false
        @call -> true
      .should.be.resolvedWith status: true

    it '`false` when child return `false`', ->
      nikita.call ({context}) ->
        @call -> true
        @call -> false
      .should.be.resolvedWith status: false
        
  describe 'inherit', ->

    it '`true` when children are [`false`, `true`]', ->
      nikita.call count: 0, ({context}) ->
        @call -> false
        @call -> true
        {}
      .should.be.resolvedWith status: true

    it '`true` when children are [`true`, `false`]', ->
      nikita.call count: 0, ({context}) ->
        @call -> false
        @call -> true
        {}
      .should.be.resolvedWith status: true

    it '`false` when children are [`false`, `false`]', ->
      nikita.call count: 0, ({context}) ->
        @call -> false
        @call -> false
        {}
      .should.be.resolvedWith status: false
