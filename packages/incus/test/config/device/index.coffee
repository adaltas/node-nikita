
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.config.device', ->
  return unless test.tags.incus

  describe 'schema', ->
    
    it 'Fail for invalid device type', ->
      nikita
      .incus.delete
        container: 'nikita-config-device-1'
        force: true
      .incus.init
        container: 'nikita-config-device-1'
        image: "images:#{test.images.alpine}"
      .incus.config.device
        container: 'nikita-config-device-1'
        device: 'test'
        type: 'invalid'
        properties:
          prop: '/tmp'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

    it 'Fail for absence of required config properties', ->
      nikita
      .incus.delete
        container: 'nikita-config-device-2'
        force: true
      .incus.init
        container: 'nikita-config-device-2'
        image: "images:#{test.images.alpine}"
      .incus.config.device
        container: 'nikita-config-device-2'
        device: 'test'
        type: 'disk'
        properties:
          prop: '/tmp'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

    it 'Fail for wrong type of config properties', ->
      nikita
      .incus.delete
        container: 'nikita-config-device-3'
        force: true
      .incus.init
        container: 'nikita-config-device-3'
        image: "images:#{test.images.alpine}"
      .incus.config.device
        container: 'nikita-config-device-3'
        device: 'test'
        type: 'disk'
        properties:
          source: key: 'value'
          path: key: 'value'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

  describe 'action', ->

    they 'Create device without properties', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @incus.delete
          container: 'nikita-config-device-4'
          force: true
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-config-device-4'
        {$status} = await @incus.config.device
          container: 'nikita-config-device-4'
          device: 'test'
          type: 'unix-char'
          properties: {} 
        $status.should.be.false()

    they 'Create device with properties', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @incus.delete
          container: 'nikita-config-device-4'
          force: true
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-config-device-4'
        {$status} = await @incus.config.device
          container: 'nikita-config-device-4'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/urandom'
            path: '/testrandom'
        $status.should.be.true()
        {$status} = await @execute
          command: "incus config device list nikita-config-device-4 | grep test"
        $status.should.be.true()

    they 'Device already created', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @incus.delete
          container: 'nikita-config-device-5'
          force: true
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-config-device-5'
        await @incus.config.device
          container: 'nikita-config-device-5'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/urandom'
            path: '/testrandom'
        {$status} = await @incus.config.device
          container: 'nikita-config-device-5'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/urandom'
            path: '/testrandom'
        $status.should.be.false()

    they 'Update device configuration', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @incus.delete
          container: 'nikita-config-device-5'
          force: true
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-config-device-5'
        await @incus.config.device
          container: 'nikita-config-device-5'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/urandom1'
            path: '/testrandom1'
        {$status} = await @incus.config.device
          container: 'nikita-config-device-5'
          device: 'test'
          type: 'unix-char'
          properties:
            source: '/dev/null'
        $status.should.be.true()
        {$status} = await @execute
          command: "incus config device show nikita-config-device-5 | grep 'source: /dev/null'"
        $status.should.be.true()

    they 'Catch and format error when creating device', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @incus.delete
          container: 'nikita-config-device-7'
          force: true
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-config-device-7'
        await @incus.config.device
          container: 'nikita-config-device-7'
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
        $ssh: ssh
      , ->
        await @incus.delete
          container: 'nikita-config-device-8'
          force: true
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-config-device-8'
        await @incus.config.device
          container: 'nikita-config-device-8'
          device: 'vpn'
          type: 'proxy'
          properties:
            listen: 'udp:127.0.0.1:1195'
            connect: 'udp:127.0.0.1:1194'
        await @incus.config.device
          container: 'nikita-config-device-8'
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
