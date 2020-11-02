
nikita = require '@nikitajs/engine/src'
assert = require 'assert'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before () ->
  await nikita
  .execute
    cmd: "lxc image copy ubuntu:default `lxc remote get-default`:"

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
        config:
          container: 'c1'
          device: 'test'
          type: 'invalid'
          config:
            prop: '/tmp'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors where found in the configuration of action `lxd.config.device`:'
          '#/oneOf config should match exactly one schema in oneOf, passingSchemas is null;'
          '#/oneOf/0/properties/config/const config.config should be equal to constant, allowedValue is {};'
          '#/oneOf/0/properties/type/const config.type should be equal to constant, allowedValue is "none";'
          '#/oneOf/1/properties/type/const config.type should be equal to constant, allowedValue is "nic";'
          '#/oneOf/10/properties/config/required config.config should have required property \'nictype\';'
          '#/oneOf/10/properties/config/required config.config should have required property \'parent\';'
          '#/oneOf/10/properties/type/const config.type should be equal to constant, allowedValue is "infiniband";'
          '#/oneOf/2/properties/config/required config.config should have required property \'path\';'
          '#/oneOf/2/properties/config/required config.config should have required property \'source\';'
          '#/oneOf/2/properties/type/const config.type should be equal to constant, allowedValue is "disk";'
          '#/oneOf/3/properties/type/const config.type should be equal to constant, allowedValue is "unix-char";'
          '#/oneOf/4/properties/type/const config.type should be equal to constant, allowedValue is "unix-block";'
          '#/oneOf/5/properties/type/const config.type should be equal to constant, allowedValue is "usb";'
          '#/oneOf/6/properties/type/const config.type should be equal to constant, allowedValue is "gpu";'
          '#/oneOf/7/properties/config/required config.config should have required property \'connect\';'
          '#/oneOf/7/properties/config/required config.config should have required property \'listen\';'
          '#/oneOf/7/properties/type/const config.type should be equal to constant, allowedValue is "proxy";'
          '#/oneOf/8/properties/config/required config.config should have required property \'path\';'
          '#/oneOf/8/properties/type/const config.type should be equal to constant, allowedValue is "unix-hotplug";'
          '#/oneOf/9/properties/type/const config.type should be equal to constant, allowedValue is "tpm".'
        ].join ' '

    it 'Fail for absence of required config properties', ->
      nikita
      .lxd.delete
        container: 'c1'
        force: true
      .lxd.init
        container: 'c1'
        image: 'ubuntu:'
      .lxd.config.device
        config:
          container: 'c1'
          device: 'test'
          type: 'disk'
          config:
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
        config:
          container: 'c1'
          device: 'test'
          type: 'disk'
          config:
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
          config:
            container: 'c1'
            device: 'test'
            type: 'unix-char'
            config:
              source: '/dev/urandom'
              path: '/testrandom'
        status.should.be.true()
        {status} = await @execute
          cmd: "lxc config device list c1 | grep test"
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
          config:
            container: 'c1'
            device: 'test'
            type: 'unix-char'
            config:
              source: '/dev/urandom'
              path: '/testrandom'
        {status} = await @lxd.config.device
          config:
            container: 'c1'
            device: 'test'
            type: 'unix-char'
            config:
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
          config:
            container: 'c1'
            device: 'test'
            type: 'unix-char'
            config:
              source: '/dev/urandom1'
              path: '/testrandom1'
        {status} = await @lxd.config.device
          config:
            container: 'c1'
            device: 'test'
            type: 'unix-char'
            config:
              source: '/dev/null'
        status.should.be.true()
        {status} = await @execute
          cmd: "lxc config device show c1 | grep 'source: /dev/null'"
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
          config:
            container: 'c1'
            device: 'vpn'
            type: 'proxy'
            config:
              listen: 'udp:127.0.0.1:1195'
              connect: 'udp:127.0.0.999:1194'
            relax: true
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
          config:
            container: 'c1'
            device: 'vpn'
            type: 'proxy'
            config:
              listen: 'udp:127.0.0.1:1195'
              connect: 'udp:127.0.0.1:1194'
        @lxd.config.device
          config:
            container: 'c1'
            device: 'vpn'
            type: 'proxy'
            config:
              listen: 'udp:127.0.0.1:1195'
              connect: 'udp:127.0.0.999:1194'
        .should.be.rejectedWith
          message: [
            'Error: Invalid devices:'
            'Device validation failed for "vpn":'
            'Invalid value for device option "connect":'
            'Not an IP address "127.0.0.999"'
          ].join ' '
