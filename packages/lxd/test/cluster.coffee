
nikita = require '@nikitajs/engine/src'
{tags} = require './test'

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita.execute
    command: "lxc image copy images:centos/7 `lxc remote get-default`:"

describe 'lxd.cluster', ->

  it 'Create container with devices', ->
    nikita ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.network.delete
        network: 'lxdbr0public'
      @lxd.network.delete
        network: 'lxdbr1private'
      @lxd.cluster
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
                config: name: 'eth0', nictype: 'bridged', parent: 'lxdbr0public'
              eth1:
                config: name: 'eth1', nictype: 'bridged', parent: 'lxdbr1private'
                ip: '10.10.10.11', netmask: '255.255.255.0'
      {status} = await @lxd.config.device.exists
        container: 'c1'
        device: 'nikitadir'
      status.should.be.true()
      {status} = await @lxd.config.device.exists
        container: 'c1'
        device: 'eth0'
      status.should.be.true()
      {status} = await @lxd.config.device.exists
        container: 'c1'
        device: 'eth1'
      status.should.be.true()

  it.skip 'prepare ssh', ->
    @timeout(-1)
    handler = ({config}) ->
      @
      .lxd.delete
        container: 'c1'
        force: true
      .lxd.network.delete
        network: 'lxdbr1private'
      .lxd.cluster
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
                config: name: 'eth1', nictype: 'bridged', parent: 'lxdbr1private'
                ip: '10.10.10.11', netmask: '255.255.255.0'
            ssh:
              enabled: config.enabled
      .network.tcp.assert
        host: '10.10.10.11'
        port: 22
        not: not config.enabled
    nikita
    .call handler, enabled: true
    .call handler, enabled: false
