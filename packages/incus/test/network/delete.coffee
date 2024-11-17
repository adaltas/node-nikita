
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.network.delete', ->
  return unless test.tags.incus

  they 'Delete a network', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.network
        name: "nkt-delete-1"
      {$status} = await @incus.network.delete
        name: "nkt-delete-1"
      $status.should.be.true()
      await @incus.network.list()
        .then ({networks}) => networks.map (network) => network.name
        .should.finally.not.containEql 'nkt-delete-1'

  they 'Network already deleted', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.network
        name: "nkt-delete-2"
      await @incus.network.delete
        name: "nkt-delete-2"
      {$status} = await @incus.network.delete
        name: "nkt-delete-2"
      $status.should.be.false()
