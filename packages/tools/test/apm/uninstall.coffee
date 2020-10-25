
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.tools_apm

describe 'tools.apm.uninstall', ->

  they 'uninstall an installed apm package', ({ssh}) ->
    {status} = await nikita
      ssh: ssh
    .tools.apm.install
      name: 'package-list'
    .tools.apm.uninstall
      name: 'package-list'
    status.should.be.true()

  they 'uninstall an apm package which is not installed', ({ssh}) ->
    {status} = await nikita
      ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm.uninstall
      name: 'package-list'
    status.should.be.false()
