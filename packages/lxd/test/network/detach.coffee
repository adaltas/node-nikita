
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

describe 'lxd.network.detach', ->

  they 'Detach a network from a container', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'u0'
        force: true
      @lxd.network.delete
        network: "testnet0"
      @lxd.init
        image: 'ubuntu:'
        container: 'u0'
      @lxd.network
        network: "testnet0"
      @lxd.network.attach
        network: "testnet0"
        container: "u0"
      {status} = await @lxd.network.detach
        network: "testnet0"
        container: "u0"
      status.should.be.true()

  they 'Network already detached', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'u0'
        force: true
      @lxd.network.delete
        network: "testnet0"
      @lxd.init
        image: 'ubuntu:'
        container: 'u0'
      @lxd.network
        network: "testnet0"
      {status} = await @lxd.network.detach
        network: "testnet0"
        container: "u0"
      status.should.be.false()
