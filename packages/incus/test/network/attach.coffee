
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.network.attach', ->
  return unless test.tags.incus

  they 'Attach a network to a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @incus.delete
          container: 'u0'
          force: true
        await @incus.network.delete
          name: "nkt-attach-1"
      try
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'u0'
        await @incus.network
          name: "nkt-attach-1"
        {$status} = await @incus.network.attach
          name: "nkt-attach-1"
          container: "u0"
        $status.should.be.true()
      finally
        await @clean()

  they 'Network already attached', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register 'clean', ->
        await @incus.delete
          container: 'u0'
          force: true
        await @incus.network.delete
          name: "nkt-attach-2"
      await @clean()
      try
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'u0'
        await @incus.network
          name: "nkt-attach-2"
        await @incus.network.attach
          name: "nkt-attach-2"
          container: "u0"
        {$status} = await @incus.network.attach
          name: "nkt-attach-2"
          container: "u0"
        $status.should.be.false()
      finally
        await @clean()
