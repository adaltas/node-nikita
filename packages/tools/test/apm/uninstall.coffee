
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_apm

describe 'tools.apm.uninstall', ->
  @timeout 60000

  they 'uninstall an installed apm package', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
      $env:
        # 'PATH': process.env['PATH'] # Required By NixOS to locate the `env` command
        'ATOM_API_URL': 'https://pulsar-edit.com/api'
    .tools.apm
      name: 'minimap'
    .tools.apm.uninstall
      name: 'minimap'
    $status.should.be.true()

  they 'uninstall an apm package which is not installed', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
      $env:
        # 'PATH': process.env['PATH'] # Required By NixOS to locate the `env` command
        'ATOM_API_URL': 'https://pulsar-edit.com/api'
    .tools.apm.uninstall
      name: 'minimap'
    .tools.apm.uninstall
      name: 'minimap'
    $status.should.be.false()

  they 'name as argument', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
      $env:
        # 'PATH': process.env['PATH'] # Required By NixOS to locate the `env` command
        'ATOM_API_URL': 'https://pulsar-edit.com/api'
    .tools.apm
      name: 'minimap'
    .tools.apm.uninstall 'minimap'
    $status.should.be.true()
