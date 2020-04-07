
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
        
  describe 'transfert', ->

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
      await nikita.call type: 'the_parent', count: 0, ({context}) ->
        @call type: 'the_child_1', -> false
        @call type: 'the_child_2', -> true
        {}
      .should.be.resolvedWith status: true

    it '`true` when children are [`true`, `false`]', ->
      await nikita.call type: 'the_parent', count: 0, ({context}) ->
        @call type: 'the_child_1', -> false
        @call type: 'the_child_2', -> true
        {}
      .should.be.resolvedWith status: true

    it '`false` when children are [`false`, `false`]', ->
      await nikita.call type: 'the_parent', count: 0, ({context}) ->
        @call type: 'the_child_1', -> false
        @call type: 'the_child_2', -> false
        {}
      .should.be.resolvedWith status: false
