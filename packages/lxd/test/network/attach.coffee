
nikita = require '@nikitajs/engine/lib'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita
  .execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.network.attach', ->

  they 'Attach a network to a container', ({ssh}) ->
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
      {status} = await @lxd.network.attach
        network: "testnet0"
        container: "u0"
      status.should.be.true()

  they 'Network already attached', ({ssh}) ->
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
      {status} = await @lxd.network.attach
        network: "testnet0"
        container: "u0"
      status.should.be.false()
