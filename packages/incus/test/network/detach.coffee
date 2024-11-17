
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.network.detach', ->
  return unless test.tags.incus

  they 'Detach a network from a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @incus.delete
          container: 'u0'
          force: true
        await @incus.network.delete
          name: "nkt-detach-1"
      await registry.register 'test', ->
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'u0'
        await @incus.network
          name: "nkt-detach-1"
        await @incus.network.attach
          name: "nkt-detach-1"
          container: "u0"
        {$status} = await @incus.network.detach
          name: "nkt-detach-1"
          container: "u0"
        $status.should.be.true()
      try
        await @clean()
        await @test()
      finally
        await @clean()

  they 'Network already detached', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @incus.delete
          container: 'u0'
          force: true
        await @incus.network.delete
          name: "nkt-detach-2"
      try
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'u0'
        await @incus.network
          name: "nkt-detach-2"
        {$status} = await @incus.network.detach
          name: "nkt-detach-2"
          container: "u0"
        $status.should.be.false()
      finally
        await @clean()
