
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
    clean = ->
      await @lxd.delete
        container: 'c1'
        force: true
      await @lxd.network.delete
        network: 'lxdbr0public'
      await @lxd.network.delete
        network: 'lxdbr1private'
    nikita ->
      @call clean
      await @lxd.cluster
        networks:
          lxdbr0public:
            'ipv4.address': '172.16.0.1/24'
            'ipv4.nat': true
            'ipv6.address': 'none'
            'dns.domain': 'nikita'
          lxdbr1private:
            'ipv4.address': '10.10.10.1/24'
            'ipv4.nat': false
            'ipv6.address': 'none'
            'dns.domain': 'nikita'
        containers:
          c1:
            image: 'images:centos/7'
            disk:
              nikitadir: source: '/nikita', path: '/nikita'
            nic:
              eth0:
                name: 'eth0', nictype: 'bridged', parent: 'lxdbr0public'
              eth1:
                name: 'eth1', nictype: 'bridged', parent: 'lxdbr1private'
                ip: '10.10.10.11', netmask: '255.255.255.0'
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
      @call clean

  they 'prepare ssh', ({ssh}) ->
    @timeout -1
    handler = ({config}) ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.network.delete
        network: 'lxdbr1private'
      @lxd.cluster
        networks:
          lxdbr1private:
            'ipv4.address': '10.10.10.1/24'
            'ipv4.nat': false
            'ipv6.address': 'none'
            'dns.domain': 'nikita'
        containers:
          c1:
            image: 'images:centos/7'
            nic:
              eth1:
                name: 'eth1', nictype: 'bridged', parent: 'lxdbr1private'
                ip: '10.10.10.11', netmask: '255.255.255.0'
            ssh:
              enabled: config.enabled
      @network.tcp.assert
        host: '10.10.10.11'
        port: 22
        not: not config.enabled
    nikita
    .call handler, enabled: true
    .call handler, enabled: false
