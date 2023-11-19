
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.info.os', ->
  return unless test.tags.system_info_os

  they 'default options', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {stdout: test.expect.os.linux_version} = await @execute 'uname -r', trim: true unless test.expect.os.linux_version
      {os} = await @system.info.os()
      Object.keys(os).sort().should.eql [
        'arch', 'distribution', 'linux_version', 'version'
      ]
      Object.keys(os).sort().should.eql Object.keys(test.expect.os).sort()
      os.should.match test.expect.os
