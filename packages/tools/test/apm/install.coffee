nikita = require '@nikitajs/core'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.tools_apm

describe 'tools.apm.install', ->

  they 'apm is installed on system', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: "if (apm -v | grep apm) then (exit 0) else (exit 1) fi"
    .promise()

  they 'install a new package which is not already installed', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm.install
      name: 'package-list'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'attempt to install a package which is already installed', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    .tools.apm.install
      name: 'package-list'
    .tools.apm.install
      name: 'package-list'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
