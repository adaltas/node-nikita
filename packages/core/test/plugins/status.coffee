
{tags} = require '../test'
nikita = require '../../src'

describe 'plugins.status', ->
  return unless tags.api
  
  describe 'returned coercion', ->

    it 'convert `true` to `{status: true}`', ->
      {status} = await nikita.call -> true
      status.should.be.true()

    it 'convert `false` to `{status: false}`', ->
      {status} = await nikita.call -> false
      status.should.be.false()

    it 'convert `{status: true}` to `{status: true}`', ->
      {status} = await nikita.call -> status: true
      status.should.be.true()

    it 'convert `{status: false}` to `{status: false}`', ->
      {status} = await nikita.call -> status: false
      status.should.be.false()
        
  describe 'last child no interference', ->

    it '`true` when child return `true`', ->
      {status} = await nikita.call ->
        @call -> false
        @call -> true
      status.should.be.true()

    it '`false` when child return `false`', ->
      {status} = await nikita.call ->
        @call -> true
        @call -> false
      status.should.be.false()
        
  describe 'inherit', ->

    it '`true` when children are [`false`, `true`]', ->
      {status} = await nikita.call count: 0, ({context}) ->
        @call -> false
        @call -> true
        {}
      status.should.be.true()

    it '`true` when children are [`true`, `false`]', ->
      {status} = await nikita.call count: 0, ({context}) ->
        @call -> false
        @call -> true
        {}
      status.should.be.true()

    it '`false` when children are [`false`, `false`]', ->
      {status} = await nikita.call count: 0, ({context}) ->
        @call -> false
        @call -> false
        {}
      status.should.be.false()
