
nikita = require '@nikitajs/core/lib'
{tags, config, expect} = require '../test'
they = require('mocha-they')(config)

return unless tags.system_info_os

describe 'system.info.os', ->

  they 'default options', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {stdout: expect.os.linux_version} = await @execute 'uname -r', trim: true unless expect.os.linux_version
      {os} = await @system.info.os()
      Object.keys(os).sort().should.eql [
        'arch', 'distribution', 'linux_version', 'version'
      ]
      Object.keys(os).sort().should.eql Object.keys(expect.os).sort()
      os.should.match expect.os
