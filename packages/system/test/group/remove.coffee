
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.group.remove', ->
  return unless test.tags.system_group
  
  they 'handle status', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @system.user.remove 'toto'
      await @system.group.remove 'toto'
      await @system.group 'toto'
      {$status} = await @system.group.remove 'toto'
      $status.should.be.true()
      {$status} = await @system.group.remove 'toto'
      $status.should.be.false()
