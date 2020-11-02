
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

describe 'lxd.network.create', ->

  they 'Create a new network', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.network.delete
        network: "testnet0"
      {status} = await @lxd.network
        network: "testnet0"
      status.should.be.true()

  they 'Different types of config parameters', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.network.delete
        network: "testnet0"
      {status} = await @lxd.network
        config:
          network: "testnet0"
          config:
            'ipv4.address': "178.16.0.1/24"
            'ipv4.dhcp': false
            'bridge.mtu': 2000
      status.should.be.true()

  they 'Network already created', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.network.delete
        network: "testnet0"
      @lxd.network
        network: "testnet0"
      {status} = await @lxd.network
        network: "testnet0"
      status.should.be.false()

  they 'Update a network', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.network.delete
        network: "testnet0"
      @lxd.network
        network: "testnet0"
      {status} = await @lxd.network
        config:
          network: "testnet0"
          config:
            'ipv4.address': "178.16.0.1/24"
            'ipv4.dhcp': false
      status.should.be.true()

  they 'Configuration unchanged', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.network
        config:
          network: "testnet0"
          config:
            'ipv4.address': "178.16.0.1/24"
      {status} = await @lxd.network
        config:
          network: "testnet0"
          config:
            'ipv4.address': "178.16.0.1/24"
      status.should.be.false()
