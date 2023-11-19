
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugin.condition', ->
  return unless test.tags.api

  it 'normalize', ->
    nikita ->
      @call
        $if: true
      , ({conditions}) ->
        conditions.if.should.be.eql [true]
  
  it 'before schema', ->
    {$status} = await nikita.call
      $if: false
      $schema:
        type: 'object'
        properties: 'a_key': type: 'boolean'
        required: ['a_key']
    , -> true
    $status.should.be.false()
    
