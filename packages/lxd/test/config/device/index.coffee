
nikita = require '@nikitajs/engine/lib'
assert = require 'assert'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

before () ->
  @timeout -1
  await nikita.execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.config.device', ->

  describe 'schema', ->
    
    it 'Fail for invalid device type', ->
      nikita
      .lxd.delete
        container: 'c1'
        force: true
      .lxd.init
        container: 'c1'
        image: 'ubuntu:'
      .lxd.config.device
        container: 'c1'
        device: 'test'
        type: 'invalid'
        properties:
          prop: '/tmp'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

    it 'Fail for absence of required config properties', ->
      nikita
      .lxd.delete
        container: 'c1'
        force: true
      .lxd.init
        container: 'c1'
        image: 'ubuntu:'
      .lxd.config.device
        container: 'c1'
        device: 'test'
        type: 'disk'
        properties:
          prop: '/tmp'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

    it 'Fail for wrong type of config properties', ->
      nikita
      .lxd.delete
        container: 'c1'
        force: true
      .lxd.init
        container: 'c1'
        image: 'ubuntu:'
      .lxd.config.device
        container: 'c1'
        device: 'test'
        type: 'disk'
        properties:
          source: 1
          path: 1
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

  describe 'action', ->

    they 'Create device', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: 'ubuntu:'
          container: 'c1'
        {status} = await @lxd.config.device
          container: 'c1'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/urandom'
            path: '/testrandom'
        status.should.be.true()
        {status} = await @execute
          command: "lxc config device list c1 | grep test"
        status.should.be.true()

    they 'Device already created', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: 'ubuntu:'
          container: 'c1'
        @lxd.config.device
          container: 'c1'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/urandom'
            path: '/testrandom'
        {status} = await @lxd.config.device
          container: 'c1'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/urandom'
            path: '/testrandom'
        status.should.be.false()

    they 'Update device configuration', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: 'ubuntu:'
          container: 'c1'
        @lxd.config.device
          container: 'c1'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/urandom1'
            path: '/testrandom1'
        {status} = await @lxd.config.device
          container: 'c1'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/null'
        status.should.be.true()
        {status} = await @execute
          command: "lxc config device show c1 | grep 'source: /dev/null'"
        status.should.be.true()

    they 'Catch and format error when creating device', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: 'ubuntu:'
          container: 'c1'
        @lxd.config.device
          container: 'c1'
          device: 'vpn'
          type: 'proxy'
          properties:
            listen: 'udp:127.0.0.1:1195'
            connect: 'udp:127.0.0.999:1194'
        .should.be.rejectedWith
          message: [
            'Error: Invalid devices:'
            'Device validation failed for "vpn":'
            'Invalid value for device option "connect":'
            'Not an IP address "127.0.0.999"'
          ].join ' '

    they 'Catch and format error when updating device configuration', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: 'ubuntu:'
          container: 'c1'
        @lxd.config.device
          container: 'c1'
          device: 'vpn'
          type: 'proxy'
          properties:
            listen: 'udp:127.0.0.1:1195'
            connect: 'udp:127.0.0.1:1194'
        @lxd.config.device
          container: 'c1'
          device: 'vpn'
          type: 'proxy'
          properties:
            listen: 'udp:127.0.0.1:1195'
            connect: 'udp:127.0.0.999:1194'
        .should.be.rejectedWith
          message: [
            'Error: Invalid devices:'
            'Device validation failed for "vpn":'
            'Invalid value for device option "connect":'
            'Not an IP address "127.0.0.999"'
          ].join ' '
