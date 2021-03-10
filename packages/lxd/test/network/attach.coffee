
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.network.attach', ->

  they 'Attach a network to a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.delete
          container: 'u0'
          force: true
        @lxc.network.delete
          network: "testnet0"
      try
        @clean()
        @lxc.init
          image: "images:#{images.alpine}"
          container: 'u0'
        @lxc.network
          network: "testnet0"
        {$status} = await @lxc.network.attach
          network: "testnet0"
          container: "u0"
        $status.should.be.true()
      finally
        @clean()

  they 'Network already attached', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        @lxc.delete
          container: 'u0'
          force: true
        @lxc.network.delete
          network: "testnet0"
      @clean()
      try
        @lxc.init
          image: "images:#{images.alpine}"
          container: 'u0'
        @lxc.network
          network: "testnet0"
        @lxc.network.attach
          network: "testnet0"
          container: "u0"
        {$status} = await @lxc.network.attach
          network: "testnet0"
          container: "u0"
        $status.should.be.false()
      finally
        @clean()
