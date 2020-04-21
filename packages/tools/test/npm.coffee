
nikita = require '@nikitajs/tools'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh...

return unless tags.tools_npm

describe 'tools.npm', ->

  they 'new package', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: 'npm uninstall -g coffeescript'
    .tools.npm
      global: true
      name: 'coffeescript'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'already installed packages', ({ssh}) ->
    nikita
      ssh: ssh
    .system.execute
      cmd: 'npm uninstall -g coffeescript'
    .tools.npm
      global: true
      name: 'coffeescript'
    .tools.npm
      global: true
      name: 'coffeescript'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'name is required', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.npm
      global: true
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'upgrade', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.npm
      upgrade: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()
