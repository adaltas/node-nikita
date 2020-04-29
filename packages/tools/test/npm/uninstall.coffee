
nikita = require '@nikitajs/tools'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.tools_npm

describe 'tools.npm.uninstall', ->

  describe 'schema', ->

    they 'name is required', ({ssh}) ->
      nikita
        ssh: ssh
      .tools.npm.uninstall
        global: true
      , (err, {status}) ->
        err.message.should.eql "should have required property '.name'"
      .promise()

    they 'name is valid', ({ssh}) ->
      nikita
        ssh: ssh
      .tools.npm.uninstall
        name: 'coffeescript'
      , ({options}) ->
        options.name.should.eql 'coffeescript'
      .promise()

    they 'use defaults', ({ssh}) ->
      nikita
        ssh: ssh
      .tools.npm.uninstall
        name: 'coffeescript'
      , ({options}) ->
        options.global.should.be.false()
      .promise()

  describe 'usage', ->

    they 'uninstall package', ({ssh}) ->
      nikita
        ssh: ssh
      .tools.npm
        global: true
        name: 'coffeescript'
      .tools.npm.uninstall
        name: 'coffeescript'
        global: true
      , (err, {status}) ->
        status.should.be.true() unless err
      .promise()

    they 'uninstall not existing package', ({ssh}) ->
      nikita
        ssh: ssh
      .tools.npm
        name: 'coffeescript'
        global: true
      .tools.npm.uninstall
        name: 'coffeescript'
        global: true
      .tools.npm.uninstall
        name: 'coffeescript'
        global: true
      , (err, {status}) ->
        status.should.be.false() unless err
      .promise()
