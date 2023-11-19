
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.storage.delete', ->
  return unless test.tags.lxd

  they 'Delete a storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.storage
        name: 'nikita-storage-delete-1'
        driver: 'zfs'
      {$status} = await @lxc.storage.delete
        name: 'nikita-storage-delete-1'
      $status.should.be.true()
      
  they 'Storage already deleted', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.storage
        name: 'nikita-storage-delete-2'
        driver: 'zfs'
      await @lxc.storage.delete
        name: 'nikita-storage-delete-2'
      {$status} = await @lxc.storage.delete
        name: 'nikita-storage-delete-2'
      $status.should.be.false()
  
