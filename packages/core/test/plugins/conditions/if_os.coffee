
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugin.conditions if_os', ->
  return unless test.tags.conditions_if_os

  they 'match distribution string', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @call
        $if_os: distribution: test.conditions_if_os.distribution
        $handler: -> true
      $status.should.be.true()
      {$status} = await @call
        $if_os: distribution: 'invalid'
        $handler: -> true
        $ssh: ssh
      $status.should.be.false()

  they 'match distribution array', ({ssh}) ->
    {$status} = await nikita
      $if_os: distribution: [test.conditions_if_os.distribution, 'invalid']
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match distribution string and version string', ({ssh}) ->
    {$status} = await nikita
      $if_os:
        distribution: test.conditions_if_os.distribution
        version: test.conditions_if_os.version
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match Linux version string', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {stdout: test.conditions_if_os.linux_version} = await @execute 'uname -r', trim: true unless test.conditions_if_os.linux_version
      {$status} = await @call
        $if_os:
          linux_version: test.conditions_if_os.linux_version
        $handler: -> true
      $status.should.be.true()

  they 'match distribution string and major version', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {stdout: test.conditions_if_os.linux_version} = await @execute 'uname -r', trim: true unless test.conditions_if_os.linux_version
      # Arch Linux has only linux_version
      if test.conditions_if_os.version
      then condition = version: test.conditions_if_os.version
      else condition = linux_version: test.conditions_if_os.linux_version
      {$status} = await @call
        $if_os: {...condition, distribution: test.conditions_if_os.distribution}
        $handler: -> true
      $status.should.be.true()

  they 'match major Linux version', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {stdout: test.conditions_if_os.linux_version} = await @execute 'uname -r', trim: true unless test.conditions_if_os.linux_version
      {$status} = await @call
        $if_os:
          linux_version: test.conditions_if_os.linux_version.split('.')[0]
        $handler: -> true
      $status.should.be.true()

  they 'match arch string', ({ssh}) ->
    {$status} = await nikita
      $if_os:
        arch: test.conditions_if_os.arch
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match distribution string, version string, Linux version string and arch string', ({ssh}) ->
    {$status} = await nikita
      $if_os: test.conditions_if_os
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()

  they 'match array', ({ssh}) ->
    # Arch Linux has only linux_version
    if test.conditions_if_os.version
    then condition = [version: test.conditions_if_os.version]
    else condition = [linux_version: test.conditions_if_os.linux_version]
    condition.push 8
    {$status} = await nikita
      $if_os: [
        distribution: test.conditions_if_os.distribution
      ,
        condition
      ]
      $handler: -> true
      $ssh: ssh
    $status.should.be.true()
