
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)
path = require('path')

return unless tags.lxd

describe 'lxc.cluster', ->
  
  before ->
    @timeout -1
    # TODO: support and replace with alpine,
    # we will have to work around networking in the machine first
    await nikita.execute
      command: "lxc image copy images:centos/7 `lxc remote get-default`:"
  
  describe 'validation', ->
    
    it 'validate container.image', ->
      nikita.lxc.cluster
        containers:
          nikita_cluster: {}
      , (->)
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      nikita.lxc.cluster
        containers:
          nikita_cluster:
            image: 'images:centos/7'
      , (->)
      .should.be.fulfilled()
  
    it 'validate disk', ->
      # Source is invalid
      nikita.lxc.cluster
        containers:
          nikita_cluster:
            image: 'images:centos/7'
            disk:
              nikitadir: true, path: '/nikita'
      , (->)
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
      nikita.lxc.cluster
        containers:
          nikita_cluster:
            image: 'images:centos/7'
            disk:
              nikitadir:
                source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
                path: '/nikita'
      , (->)
      .should.be.fulfilled()

  they 'Create container with devices', ({ssh}) ->
    @timeout -1 # yum install take a lot of time
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register ['clean'], ->
        await @lxc.delete
          container: 'nikita-cluster-1'
          force: true
        await @lxc.network.delete
          network: 'nktlxdpub'
        await @lxc.network.delete
          network: 'nktlxdprv'
      @clean()
      await @lxc.cluster
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
          'nikita-cluster-1':
            image: 'images:centos/7'
            disk:
              nikitadir:
                source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
                path: '/nikita'
            nic:
              eth0:
                name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
              eth1:
                name: 'eth1', nictype: 'bridged', parent: 'nktlxdprv'
                ip: '192.0.2.5', netmask: '255.255.255.0'
      await @wait time: 200
      {exists} = await @lxc.config.device.exists
        container: 'nikita-cluster-1'
        device: 'nikitadir'
      exists.should.be.true()
      {exists} = await @lxc.config.device.exists
        container: 'nikita-cluster-1'
        device: 'eth0'
      exists.should.be.true()
      {exists} = await @lxc.config.device.exists
        container: 'nikita-cluster-1'
        device: 'eth1'
      exists.should.be.true()
      @clean()

  they 'prepare ssh', ({ssh}) ->
    @timeout -1
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @lxc.delete
          container: 'nikita-cluster-2'
          force: true
        await @lxc.network.delete
          network: 'nktlxdprv'
      await registry.register 'test', ({config}) ->
        await @lxc.cluster
          networks:
            nktlxdprv:
              'ipv4.address': '192.0.2.5/30'
              'ipv4.nat': true
              'ipv6.address': 'none'
              'dns.domain': 'nikita.local'
          containers:
            'nikita-cluster-2':
              image: 'images:centos/7'
              nic:
                eth0: # Overwrite the default DHCP Nat enabled interface
                  name: 'eth0', nictype: 'bridged', parent: 'nktlxdprv'
                  ip: '192.0.2.6', netmask: '255.255.255.0'
              ssh:
                enabled: config.enabled
        await @lxc.exec
          container: 'nikita-cluster-2'
          command: '''
          echo > /dev/tcp/192.0.2.6/22
          '''
          code: if config.enabled then 0 else 1
          shell: 'bash'
      try
        await @clean()
        await @test enabled: true
        await @clean()
        await @test enabled: false
      finally
        await @clean()
