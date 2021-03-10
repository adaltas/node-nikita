
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.network.delete', ->

  they 'Delete a network', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.network
        network: "testnet0"
      {$status} = await @lxc.network.delete
        network: "testnet0"
      $status.should.be.true()
          
  they 'Network already deleted', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.network
        network: "testnet0"
      @lxc.network.delete
        network: "testnet0"
      {$status} = await @lxc.network.delete
        network: "testnet0"
      $status.should.be.false()
