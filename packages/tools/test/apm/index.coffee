
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_apm

describe 'tools.apm', ->
  @timeout 60000

  they.skip 'install a new package which is not already installed', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
      $env:
        # 'PATH': process.env['PATH'] # Required By NixOS to locate the `env` command
        'ATOM_API_URL': 'https://pulsar-edit.com/api'
    .execute
      command: 'env'
    .tools.apm.uninstall
      name: 'minimap'
    .tools.apm
      name: 'minimap'
    $status.should.be.true()

  they 'attempt to install a package which is already installed', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
      $env:
        # 'PATH': process.env['PATH'] # Required By NixOS to locate the `env` command
        'ATOM_API_URL': 'https://pulsar-edit.com/api'
    .tools.apm.uninstall
      name: 'minimap'
    .tools.apm
      name: 'minimap'
    .tools.apm
      name: 'minimap'
    $status.should.be.false()
    
  they 'name as argument', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
      $env:
        # 'PATH': process.env['PATH'] # Required By NixOS to locate the `env` command
        'ATOM_API_URL': 'https://pulsar-edit.com/api'
    .tools.apm.uninstall
      name: 'minimap'
    .tools.apm 'minimap'
    $status.should.be.true()
