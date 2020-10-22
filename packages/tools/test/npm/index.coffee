
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.tools_npm

describe 'tools.npm', ->

  describe 'schema', ->

    it 'name is required', ->
      nikita
      .tools.npm {}
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `tools.npm`:'
          '#/required config should have required property \'name\'.'
        ].join ' '

  describe 'action', ->

    # combined, since the tests are time consuming
    they 'install a package localy and globaly', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        await @tools.npm.uninstall
          name: 'coffeescript'
        await @tools.npm.uninstall
          config:
            name: 'coffeescript'
            global: true
            sudo: true
        {status} = await @tools.npm
          name: 'coffeescript'
        status.should.be.true()
        {status} = await @tools.npm
          name: 'coffeescript'
        status.should.be.false()
        {status} = await @tools.npm
          config:
            name: 'coffeescript'
            global: true
            sudo: true
        status.should.be.true()
        {status} = await @tools.npm
          config:
            name: 'coffeescript'
            global: true
            sudo: true
        status.should.be.false()
    
    they 'install many packages', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        await @tools.npm.uninstall
          name: ['coffeescript', 'csv']
        {status} = await @tools.npm
          name: ['coffeescript', 'csv']
        status.should.be.true()
        {status} = await @tools.npm
          name: ['coffeescript', 'csv']
        status.should.be.false()

    they 'upgrade a package', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        await @tools.npm.uninstall
          name: 'coffeescript'
        await @tools.npm
          name: 'coffeescript@2.0'
        {status} = await @tools.npm
          name: 'coffeescript'
          upgrade: true
        status.should.be.true()
  
