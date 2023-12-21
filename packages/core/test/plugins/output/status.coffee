
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.output.status', ->
  return unless test.tags.api
  
  describe 'returned coercion', ->

    it 'convert `true` to `{$status: true}`', ->
      {$status} = await nikita.call -> true
      $status.should.be.true()

    it 'convert `false` to `{$status: false}`', ->
      {$status} = await nikita.call -> false
      $status.should.be.false()

    it 'convert `{$status: true}` to `{$status: true}`', ->
      {$status} = await nikita.call -> $status: true
      $status.should.be.true()

    it 'convert `{status: false}` to `{status: false}`', ->
      {$status} = await nikita.call -> $status: false
      $status.should.be.false()

    it 'otherwise no coercion', ->
      result = await nikita.call -> 'ok'
      result.should.eql 'ok'
      result = await nikita.call -> []
      result.should.eql []
      result = await nikita.call -> null
      should(result).be.null()
        
  describe 'last child no interference', ->

    it '`true` when child return `true`', ->
      {$status} = await nikita.call ->
        await @call -> false
        await @call -> true
      $status.should.be.true()

    it '`false` when child return `false`', ->
      {$status} = await nikita.call ->
        await @call -> true
        await @call -> false
      $status.should.be.false()
        
  describe 'inherit', ->

    it '`true` when children are [`false`, `true`]', ->
      {$status} = await nikita.call count: 0, ->
        await @call -> false
        await @call -> true
        {}
      $status.should.be.true()

    it '`true` when children are [`true`, `false`]', ->
      {$status} = await nikita.call count: 0, ->
        await @call -> false
        await @call -> true
        {}
      $status.should.be.true()

    it '`false` when children are [`false`, `false`]', ->
      {$status} = await nikita.call count: 0, ->
        await @call -> false
        await @call -> false
        {}
      $status.should.be.false()
