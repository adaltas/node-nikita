
nikita = require '../../../lib'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'plugins.execute', ->
  return unless tags.api

  describe 'usage', ->

    it 'arch chroot properties', ->
      config = await nikita
        $arch_chroot: false
        $arch_chroot_rootdir: '/tmp'
      , ->
        @execute 'fake cmd', ({config}) -> config
      config.arch_chroot.should.eql false
      config.arch_chroot_rootdir.should.eql '/tmp'

    it 'other properties', ->
      config = await nikita
        $bash: true
        $dry: true
        $env: key: 'value'
        $env_export: true
      , ->
        @execute 'fake cmd', ({config}) -> config
      config.bash.should.eql true
      config.dry.should.eql true
      config.env.should.containEql key: 'value'
      config.env_export.should.eql true
      should(config.sudo).be.undefined()
    
    it 'schema validation', ->
      nikita
        $sudo: 'Oh no'
      .should.be.rejectedWith [
        'NIKITA_SCHEMA_VALIDATION_CONFIG:'
        'one error was found in the configuration of root action:'
        'nikita#/definitions/metadata/properties/sudo/type metadata/sudo must be boolean,'
        'type is "boolean".'
      ].join ' '

  describe 'env', ->

    they 'merge parent metadata with config', ({ssh}) ->
      nikita
        ssh: ssh
        $env: 'NIKITA_PROCESS_ENV_1': '1'
      , ->
        {env} = await @execute
          command: 'env'
          env: 'NIKITA_PROCESS_ENV_2': '2'
        , ({config}) -> env: config.env
        env.should.eql
          NIKITA_PROCESS_ENV_1: '1'
          NIKITA_PROCESS_ENV_2: '2'

    they 'process.env disabled if env is provided in parent', ({ssh}) ->
      nikita
        ssh: ssh
        $env:
          # Required By NixOS to locate the `env` command
          'PATH': process.env['PATH']
          'NIKITA_PROCESS_ENV': '1'
      , ->
        process.env['NIKITA_INVALID_ENV'] = '1'
        {stdout} = await @execute
          command: 'env'
        stdout.split('\n').includes('NIKITA_PROCESS_ENV=1').should.be.true()
        stdout.split('\n').includes('NIKITA_INVALID_ENV=1').should.be.false()
