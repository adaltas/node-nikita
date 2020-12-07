
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.tools_npm

describe 'tools.npm', ->

  describe 'schema', ->

    it 'name or upgrade is required', ->
      nikita
      .tools.npm {}
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors where found in the configuration of action `tools.npm`:'
          '#/oneOf config should match exactly one schema in oneOf, passingSchemas is null;'
          '#/oneOf/0/required config should have required property \'name\';'
          '#/oneOf/1/required config should have required property \'upgrade\'.'
        ].join ' '

  describe 'action', ->

    they 'install localy', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {status} = await @tools.npm
          cwd: tmpdir
          name: 'coffeescript'
        status.should.be.true()
        {status} = await @tools.npm
          cwd: tmpdir
          name: 'coffeescript'
        status.should.be.false()

    they 'install localy in a current working directory', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.mkdir "#{tmpdir}/1_dir"
        @fs.mkdir "#{tmpdir}/2_dir"
        {status} = await @tools.npm
          name: 'coffeescript'
          cwd: "#{tmpdir}/1_dir"
        status.should.be.true()
        {status} = await @tools.npm
          name: 'coffeescript'
          cwd: "#{tmpdir}/2_dir"
        status.should.be.true()

    they 'install globaly', ({ssh}) ->
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
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {status} = await @tools.npm
          cwd: tmpdir
          name: ['coffeescript', 'csv']
        status.should.be.true()
        {status} = await @tools.npm
          cwd: tmpdir
          name: ['coffeescript', 'csv']
        status.should.be.false()

    they 'upgrade all outdated packages', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @tools.npm
          cwd: tmpdir
          name: 'coffeescript@2.0'
        {status} = await @tools.npm
          cwd: tmpdir
          upgrade: true
        status.should.be.true()
        {status} = await @tools.npm
          cwd: tmpdir
          upgrade: true
        status.should.be.false()

    they 'name as argument', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {status} = await @tools.npm 'coffeescript',
          cwd: tmpdir
        status.should.be.true()
  
