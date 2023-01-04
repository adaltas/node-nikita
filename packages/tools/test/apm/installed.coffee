
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.tools_apm

describe 'tools.apm.install', ->
  @timeout 60000

  they 'apm is installed on system', ({ssh}) ->
    {$status} = await nikita
      $ssh: ssh
      $env:
        # 'PATH': process.env['PATH'] # Required By NixOS to locate the `env` command
        'ATOM_API_URL': 'https://pulsar-edit.com/api'
    .tools.apm.installed()
    $status.should.be.true()
