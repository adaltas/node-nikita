
nikita = require '@nikitajs/engine/lib'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before ->
  @timeout -1
  await nikita.execute
    command: "lxc image copy images:centos/7 `lxc remote get-default`:"

describe 'lxd.cluster', ->
  
  describe 'validation', ->
    
    it 'validate container.image', ->
      nikita.lxd.cluster
        handler: (->)
        config:
          containers:
            c1: {}
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      nikita.lxd.cluster
        handler: (->)
        config:
          containers:
            c1:
              image: 'images:centos/7'
      .should.be.fulfilled()
  
    it 'validate disk', ->
      # Source is invalid
      nikita.lxd.cluster
        handler: (->)
        config:
          containers:
            c1:
              image: 'images:centos/7'
              disk:
                nikitadir: true, path: '/nikita'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      nikita.lxd.cluster
        handler: (->)
        config:
          containers:
            c1:
              image: 'images:centos/7'
              disk:
                nikitadir: source: '/nikita', path: '/nikita'
      .should.be.fulfilled()

  they 'Create container with devices', ({ssh}) ->
    @timeout -1 # yum install take a lot of time
    nikita
      ssh: ssh
    , ({registry}) ->
      await registry.register ['clean'], ->
        await @lxd.delete
          container: 'c1'
          force: true
        await @lxd.network.delete
          network: 'nktlxdpub'
        await @lxd.network.delete
          network: 'nktlxdprv'
      @clean()
      await @lxd.cluster
        networks:
          nktlxdpub:
            'ipv4.address': '192.0.2.1/30'
            'ipv4.nat': true
            'ipv6.address': 'none'
            'dns.domain': 'nikita.local'
          nktlxdprv:
            'ipv4.address': '192.0.2.5/30'
            'ipv4.nat': false
            'ipv6.address': 'none'
            'dns.domain': 'nikita.local'
        containers:
          c1:
            image: 'images:centos/7'
            disk:
              nikitadir: source: '/nikita', path: '/nikita'
            nic:
              eth0:
                name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
              eth1:
                name: 'eth1', nictype: 'bridged', parent: 'nktlxdprv'
                ip: '192.0.2.5', netmask: '255.255.255.0'
      await @wait time: 200
      {exists} = await @lxd.config.device.exists
        container: 'c1'
        device: 'nikitadir'
      exists.should.be.true()
      {exists} = await @lxd.config.device.exists
        container: 'c1'
        device: 'eth0'
      exists.should.be.true()
      {exists} = await @lxd.config.device.exists
        container: 'c1'
        device: 'eth1'
      exists.should.be.true()
      @clean()

  they 'prepare ssh', ({ssh}) ->
    @timeout -1
    nikita
      ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.network.delete
          network: 'nktlxdprv'
      await registry.register 'test', ({config}) ->
        @lxd.cluster
          networks:
            nktlxdprv:
              'ipv4.address': '192.0.2.5/30'
              'ipv4.nat': true
              'ipv6.address': 'none'
              'dns.domain': 'nikita.local'
          containers:
            c1:
              image: 'images:centos/7'
              nic:
                eth0: # Overwrite the default DHCP Nat enabled interface
                  name: 'eth0', nictype: 'bridged', parent: 'nktlxdprv'
                  ip: '192.0.2.6', netmask: '255.255.255.0'
              ssh:
                enabled: config.enabled
        @lxd.exec
          container: 'c1'
          command: '''
          echo > /dev/tcp/192.0.2.6/22
          '''
          code: if config.enabled then 0 else 1
      try
        await @clean()
        await @test enabled: true
        await @clean()
        await @test enabled: false
      finally
        await @clean()
