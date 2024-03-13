import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.storage.volume.list', ->
  return unless test.tags.incus

  they 'list all volumes in a pool', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @incus.storage.volume.delete 
          pool: 'nikita-storage-list-1'
          name: 'nikita-volume-list-1'
        await @incus.storage.delete
          name: 'nikita-storage-list-1'
      await @clean()
      await @incus.storage
        name: 'nikita-storage-list-1'
        driver: "zfs"
      await @incus.storage.volume
        name: 'nikita-volume-list-1'
        pool: 'nikita-storage-list-1'
      {$status, list} = await @incus.storage.volume.list
        pool: 'nikita-storage-list-1'
      $status.should.be.eql true 
      list.should.containEql 'nikita-volume-list-1'
      await @clean()

  they 'list all volumes in an non-existing pool', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {$status} = await @incus.storage.volume.list
        pool: 'nikita-storage-list-2'
      $status.should.be.eql false
