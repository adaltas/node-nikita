import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.storage.volume.list', ->
  return unless test.tags.lxd

  they 'list all volumes in a pool', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @lxc.storage.volume.delete 
          pool: 'nikita-storage-list-1'
          name: 'nikita-volume-list-1'
        await @lxc.storage.delete
          name: 'nikita-storage-list-1'
      await @clean()
      await @lxc.storage
        name: 'nikita-storage-list-1'
        driver: "zfs"
      await @lxc.storage.volume
        name: 'nikita-volume-list-1'
        pool: 'nikita-storage-list-1'
      {$status, list} = await @lxc.storage.volume.list
        pool: 'nikita-storage-list-1'
      $status.should.be.eql true 
      list.should.containEql 'nikita-volume-list-1'
      await @clean()

  they 'list all volumes in an non-existing pool', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @lxc.storage.volume.list
        pool: 'nikita-storage-list-2'
      $status.should.be.eql false
