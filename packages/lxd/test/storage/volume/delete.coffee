nikita = require '@nikitajs/core/lib'
{config, tags} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.storage.volume.delete', ->

  they 'delete a volume', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.storage
        name: 'nikita-storage-delete-1'
        driver: "zfs"
      await @lxc.storage.volume
        name: 'nikita-volume-delete-1'
        pool: 'nikita-storage-delete-1'
      {$status} = await @lxc.storage.volume.delete 
        pool: 'nikita-storage-delete-1'
        name: 'nikita-volume-delete-1'
      await @lxc.storage.delete
        name: 'nikita-storage-delete-1'
      $status.should.be.eql true
  
  they 'double delete a volume', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.storage
        name: 'nikita-storage-delete-2'
        driver: "zfs"
      await @lxc.storage.volume
        name: 'nikita-volume-delete-2'
        pool: 'nikita-storage-delete-2'
      await @lxc.storage.volume.delete 
        pool: 'nikita-storage-delete-2'
        name: 'nikita-volume-delete-2'
      {$status} = await @lxc.storage.volume.delete 
        pool: 'nikita-storage-delete-2'
        name: 'nikita-volume-delete-2'
      await @lxc.storage.delete
        name: 'nikita-storage-delete-2'
      $status.should.be.eql false
