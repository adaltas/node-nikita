
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugin.conditions unless_os', ->
  return unless test.tags.conditions_if_os

  they 'match distribution string', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @call
        $unless_os: distribution: test.conditions_if_os.distribution
        $handler: -> true
      $status.should.be.false()
      {$status} = await @call
        $unless_os: distribution: 'invalid'
        $handler: -> true
      $status.should.be.true()

  they 'match distribution array', ({ssh}) ->
    {$status} = await nikita
      $unless_os: distribution: ['invalid1', 'invalid2']
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()
    
  they 'match distribution string and version string', ({ssh}) ->
    # Arch Linux only has linux_version
    if test.conditions_if_os.version
    then condition = version: '1'
    else condition = linux_version: '1'
    {$status} = await nikita
      $unless_os: {...condition, distribution: 'invalid' }
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match Linux version string', ({ssh}) ->
    {$status} = await nikita
      $unless_os:
        linux_version: '1'
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()
    
  they 'match distribution string, version string, Linux version string and arch string', ({ssh}) ->
    {$status} = await nikita
      $unless_os: test.conditions_if_os
      $handler: -> true
      $ssh: ssh
    $status.should.be.false()

  they 'match array', ({ssh}) ->
    {$status} = await nikita
      $unless_os: [
        { distribution: ['invalid1', 'invalid2'] }
        { distribution: 'invalid' }
      ]
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()
