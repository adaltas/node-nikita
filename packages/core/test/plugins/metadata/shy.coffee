
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'plugins.metadata.shy', ->
  return unless test.tags.api

  it 'dont alter status', ->
    {$status} = await nikita ->
      await @call $shy: true, -> true
      await @call -> false
      undefined
    $status.should.eql false

  it 'doesnt apply to output', ->
    {$status} = await nikita ->
      {$status} = await @call $shy: true, -> true
      $status.should.eql true
      undefined
    $status.should.eql false

  it 'output from array', ->
    nikita ->
      {$status} = await @call ->
        [act1, act2] = await @call [
          $shy: true
          $handler: -> true
        ,
          $shy: false
          $handler: -> false
        ]
        act1.$status.should.be.true()
        act2.$status.should.be.false()
        undefined
      $status.should.be.false()
  
  it 'false disreregard a status true', ->
    nikita ->
      {$status} = await @call ->
        [act1, act2] = await @call [
          $shy: false
          $handler: -> true
        ,
          $shy: true
          $handler: -> false
        ]
        act1.$status.should.be.true()
        act2.$status.should.be.false()
        undefined
      $status.should.be.true()
