
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.storage.delete', ->
  return unless test.tags.incus

  they 'Delete a storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.storage
        name: 'nikita-storage-delete-1'
        driver: 'zfs'
      {$status} = await @incus.storage.delete
        name: 'nikita-storage-delete-1'
      $status.should.be.true()
      
  they 'Storage already deleted', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.storage
        name: 'nikita-storage-delete-2'
        driver: 'zfs'
      await @incus.storage.delete
        name: 'nikita-storage-delete-2'
      {$status} = await @incus.storage.delete
        name: 'nikita-storage-delete-2'
      $status.should.be.false()
  
