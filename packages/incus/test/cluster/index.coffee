
import path from 'node:path'
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)
__dirname = new URL( '.', import.meta.url).pathname

describe 'incus.cluster', ->
  return unless test.tags.incus

  describe 'validation', ->

    it 'validate container.image', ->
      nikita.incus.cluster
        containers:
          nikita_cluster: {}
      , (->)
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      nikita.incus.cluster
        containers:
          nikita_cluster:
            image: 'images:centos/7'
      , (->)
      .should.be.fulfilled()

    it 'validate disk', ->
      # Source is invalid
      nikita.incus.cluster
        containers:
          nikita_cluster:
            image: 'images:centos/7'
            disk:
              nikitadir: true, path: '/nikita'
      , (->)
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      nikita.incus.cluster
        containers:
          nikita_cluster:
            image: 'images:centos/7'
            disk:
              nikitadir:
                source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
                path: '/nikita'
      , (->)
      .should.be.fulfilled()

  they 'Create multiple devices', ({ssh}) ->
    @timeout -1 # yum/apk install take a lot of time
    nikita
      $ssh: ssh
    , ({registry}) ->
      cluster =
        networks:
          nktincuspub:
            'ipv4.address': '10.10.40.1/24'
            'ipv4.nat': true
            'ipv6.address': 'none'
          nktincusprv:
            'ipv4.address': '10.10.50.1/24'
            'ipv4.nat': false
            'ipv6.address': 'none'
            'dns.domain': 'nikita.local'
        containers:
          'nikita-cluster-1':
            image: "images:#{test.images.alpine}"
            disk:
              nikitadir:
                source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
                path: '/nikita'
            nic:
              eth0:
                name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
              eth1:
                name: 'eth1', nictype: 'bridged', parent: 'nktincusprv'
                'ipv4.address': '10.10.50.11'
      await registry.register ['clean'], ->
        await @incus.delete
          container: 'nikita-cluster-1'
          force: true
        await @incus.network.delete 'nktincuspub'
        await @incus.network.delete 'nktincusprv'
      await registry.register ['test'], ->
        await @incus.cluster cluster
        {exists} = await @incus.config.device.exists
          container: 'nikita-cluster-1'
          device: 'nikitadir'
        exists.should.be.true()
        {exists} = await @incus.config.device.exists
          container: 'nikita-cluster-1'
          device: 'eth0'
        exists.should.be.true()
        {exists} = await @incus.config.device.exists
          container: 'nikita-cluster-1'
          device: 'eth1'
        exists.should.be.true()
      try
        await @clean()
        await @test()
      catch err
        await @clean()
      finally
        await @clean()

  they 'ip and ssh', ({ssh}) ->
    @timeout -1
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @incus.delete
          container: 'nikita-cluster-2'
          force: true
        await @incus.network.delete 'nktincusprv'
      await registry.register 'test', ({config}) ->
        await @incus.cluster
          networks:
            nktincusprv:
              'ipv4.address': '192.0.2.5/30'
              'ipv4.nat': true
              'ipv6.address': 'none'
              'dns.domain': 'nikita.local'
          containers:
            'nikita-cluster-2':
              image: "images:#{test.images.alpine}"
              nic:
                eth0: # Overwrite the default DHCP Nat enabled interface
                  name: 'eth0', nictype: 'bridged', parent: 'nktincusprv'
                  'ipv4.address': '192.0.2.6'
              ssh:
                enabled: config.enabled
        await @incus.exec
          container: 'nikita-cluster-2'
          command: '''
          nc -zvw2 192.0.2.6 22
          '''
          code: if config.enabled then 0 else 1
      try
        await @clean()
        await @test enabled: true
        await @clean()
        await @test enabled: false
      catch err
        await @clean()
      finally
        await @clean()

  return unless test.tags.incus_vm

  they 'init properties with vm', ({ssh}) ->
    @timeout -1
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @incus.delete
          container: 'nikita-cluster-3'
          force: true
      await registry.register 'test', ->
        await @incus.cluster
          containers:
            'nikita-cluster-3':
              image: "images:centos/7"
              vm: true
              properties:
                'security.secureboot': false
              ssh: enabled: true
        {$status} = await @incus.state.running
          container: 'nikita-cluster-3'
        $status.should.be.eql true
      try
        await @clean()
        await @test()
      catch err
        await @clean()
      finally
        await @clean()
