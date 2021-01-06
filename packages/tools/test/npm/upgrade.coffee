
nikita = require '@nikitajs/engine/lib'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.tools_npm

describe 'tools.npm.upgrade', ->

  describe 'schema', ->

    it 'cwd or global is true are required', ->
      nikita {}
      , ->
        @tools.npm.upgrade {}
        .should.be.rejectedWith
          code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
          message: [
            'NIKITA_SCHEMA_VALIDATION_CONFIG:'
            'multiple errors where found in the configuration of action `tools.npm.upgrade`:'
            '#/if config should match "then" schema, failingKeyword is "then";'
            '#/then/required config should have required property \'cwd\'.'
          ].join ' '
        @tools.npm.upgrade
          config:
            global: true
        .should.eventually.not.be.rejected

  describe 'action', ->

    they 'upgrade packages locally', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @tools.npm
          cwd: tmpdir
          name: 'coffeescript@2.0'
        {status} = await @tools.npm.upgrade
          cwd: tmpdir
        status.should.be.true()
        {status} = await @tools.npm.upgrade
          cwd: tmpdir
        status.should.be.false()

    they 'upgrade packages globally', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        await @tools.npm.uninstall
          config:
            name: 'coffeescript'
            global: true
            sudo: true
        {status} = await @tools.npm
          config:
            name: 'coffeescript@2.0'
            global: true
            sudo: true
        status.should.be.true()
        {status} = await @tools.npm.upgrade
          config:
            global: true
            sudo: true
        status.should.be.true()
        {status} = await @tools.npm.upgrade
          config:
            global: true
            sudo: true
        status.should.be.false()
