
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'plugins.execute', ->
  return unless tags.api

  describe 'usage', ->

    it 'supported properties', ->
      config = await nikita
        $arch_chroot: false
        $arch_chroot_rootdir: '/tmp'
        $bash: true
        $dry: true
        $env: key: 'value'
        $env_export: true
        $sudo: true
      , ->
        @execute 'fake cmd', ({config}) -> config
      config.arch_chroot.should.eql false
      config.arch_chroot_rootdir.should.eql '/tmp'
      config.bash.should.eql true
      config.dry.should.eql true
      config.env.should.containEql key: 'value'
      config.env_export.should.eql true
      config.sudo.should.eql true

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
