
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.tools_apm

describe 'tools.apm.install', ->

  they 'apm is installed on system', ({ssh}) ->
    {status} = await nikita
      ssh: ssh
    .tools.apm.installed()
    status.should.be.true()
