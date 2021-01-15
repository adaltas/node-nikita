
nikita = require '@nikitajs/engine/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_apm

describe 'tools.apm.install', ->

  they 'install a new package which is not already installed', ({ssh}) ->
    {status} = await nikita
      ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm.install
      name: 'package-list'
    status.should.be.true()

  they 'attempt to install a package which is already installed', ({ssh}) ->
    {status} = await nikita
      ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm.install
      name: 'package-list'
    .tools.apm.install
      name: 'package-list'
    status.should.be.false()
    
  they 'name as argument', ({ssh}) ->
    {status} = await nikita
      ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm.install 'package-list'
    status.should.be.true()
