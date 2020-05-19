
nikita = require '@nikitajs/core'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.tools_apm

describe 'tools.apm.uninstall', ->

  they 'uninstall an installed apm package', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.apm.install
      name: 'package-list'
    .tools.apm.uninstall
      name: 'package-list'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'uninstall an apm package which is not installed', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.apm.uninstall
      name: 'package-list'
    , (err) ->
      throw err if err
    .tools.apm.uninstall
      name: 'package-list'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
