
stream = require 'stream'
nikita = require '../../../lib'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.execute.config.env_export', ->
  return unless tags.posix

  they 'env in execute action', ({ssh}) ->
    nikita $ssh: ssh, ->
      logs = []
      {stdout} = await @execute
        command: 'env'
        env:
          # Required By NixOS to locate the `env` command
          'PATH': process.env['PATH']
          'MY_KEY': 'MY VALUE'
        env_export: true
        $log: ({log}) ->
          return unless log.type is 'text'
          logs.push log.message if /^Writing env export/.test log.message
      stdout.split('\n').includes('MY_KEY=MY VALUE').should.be.true()
      logs.length.should.eql 1

  they 'env in parent action', ({ssh}) ->
    nikita
      $ssh: ssh
      $env:
        # Required By NixOS to locate the `env` command
        'PATH': process.env['PATH']
        'MY_KEY': 'MY VALUE'
    ,->
      @call ->
        logs = []
        {stdout} = await @execute
          command: 'env'
          env_export: true
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log.message if /^Writing env export/.test log.message
        stdout.split('\n').includes('MY_KEY=MY VALUE').should.be.true()
        logs.length.should.eql 1

  they 'env merged with parent action', ({ssh}) ->
    nikita
      $ssh: ssh
      $env:
        # Required By NixOS to locate the `env` command
        'PATH': process.env['PATH']
        'MY_KEY_1': 'MY VALUE 1'
    ,->
      @call
        $env: 'MY_KEY_2': 'MY VALUE 2'
      , ->
        logs = []
        {stdout} = await @execute
          command: 'env'
          env: 'MY_KEY_3': 'MY VALUE 3'
          env_export: true
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log.message if /^Writing env export/.test log.message
        stdout.split('\n').includes('MY_KEY_1=MY VALUE 1').should.be.true()
        stdout.split('\n').includes('MY_KEY_2=MY VALUE 2').should.be.true()
        stdout.split('\n').includes('MY_KEY_3=MY VALUE 3').should.be.true()
        logs.length.should.eql 1

  they.skip 'dont write if someone did it', ({ssh}) ->
    # Note, caching of generated env file would hard to implement
    # It can't be inside execute with tempdir, the file is automatically
    # disposed when the execute action is done
    # It must be implemented as a plugin, written before first execute action
    # and, in case execute doesn't defined any env properties,
    # disposed by the parent action
    # Note, env_export_hash is not yet returned by execute.
    nikita
      $ssh: ssh
      $env:
        # Required By NixOS to locate the `env` command
        'PATH': process.env['PATH']
        'MY_KEY_1': 'MY VALUE 1'
    , ({metadata: {tmpdir}}) ->
      @call
        # Required By NixOS to locate the `env` command
        'PATH': process.env['PATH']
        $env: 'MY_KEY_2': 'MY VALUE 2'
      , ->
        logs = []
        {stdout, env_export_hash} = await @execute
          command: 'env'
          env_export: true
        # Check the env_export_hash value
      @call
        $env:
          'PATH': process.env['PATH']
          'MY_KEY_2': 'MY VALUE 2'
      , ->
        logs = []
        {stdout, env_export_hash} = await @execute
          command: 'env'
          env_export: true
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log.message if /^Writing env export/.test log.message
        # Check the env_export_hash value shall be the same
        # stdout.split('\n').includes('MY_KEY_1=MY VALUE 1').should.be.true()
        # stdout.split('\n').includes('MY_KEY_2=MY VALUE 2').should.be.true()
        # stdout.split('\n').includes('MY_KEY_3=MY VALUE 3').should.be.true()
        logs.length.should.eql 0
