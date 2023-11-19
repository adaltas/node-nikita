
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.network.delete', ->
  return unless test.tags.lxd

  they 'Delete a network', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.network
        network: "nkt-delete-1"
      {$status} = await @lxc.network.delete
        network: "nkt-delete-1"
      $status.should.be.true()
      {list} = await @lxc.network.list()
      list.should.not.containEql 'nkt-delete-1'
          
  they 'Network already deleted', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.network
        network: "nkt-delete-2"
      await @lxc.network.delete
        network: "nkt-delete-2"
      {$status} = await @lxc.network.delete
        network: "nkt-delete-2"
      $status.should.be.false()
