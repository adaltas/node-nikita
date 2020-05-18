
nikita = require '@nikitajs/core'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.tools_apm

describe 'tools.apm.uninstall', ->

  they 'uninstall apm package using tools.apm.uninstall', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.apm.install
      name: 'package-list'
    .tools.apm.uninstall
      name: 'package-list'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()
