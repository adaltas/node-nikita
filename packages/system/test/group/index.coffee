
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.group', ->
  return unless test.tags.system_group
  
  they 'accept only user name', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @system.user.remove 'toto'
      await @system.group.remove 'toto'
      {$status} = await @system.group 'toto'
      $status.should.be.true()
      {$status} = await @system.group 'toto'
      $status.should.be.false()

  they 'accept gid as int or string', ({ssh, sudo}) ->
    nikita
      $ssh: ssh
      $sudo: sudo
    , ->
      await @system.user.remove 'toto'
      await @system.group.remove 'toto'
      {$status} = await @system.group 'toto', gid: '1234'
      $status.should.be.true()
      {$status} = await @system.group 'toto', gid: '1234'
      $status.should.be.false()
      {$status} = await @system.group 'toto', gid: 1234
      $status.should.be.false()

  they 'throw if empty gid string', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @system.group.remove 'toto'
      await @system.group 'toto', gid: ''
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
  
