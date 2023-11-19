import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.storage.volume.get', ->
  return unless test.tags.lxd

  they 'get a volume', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @lxc.storage.volume.delete 
          pool: 'nikita-storage-get-1'
          name: 'nikita-volume-get-1'
        await @lxc.storage.delete
          name: 'nikita-storage-get-1'
      await @clean()
      await @lxc.storage
        name: 'nikita-storage-get-1'
        driver: "zfs"
      await @lxc.storage.volume
        name: 'nikita-volume-get-1'
        pool: 'nikita-storage-get-1'
      {$status, data} = await @lxc.storage.volume.get
        pool: 'nikita-storage-get-1'
        name: 'nikita-volume-get-1'
      $status.should.be.eql true
      data.name.should.be.eql 'nikita-volume-get-1'
      await @clean()
  
  they "get a volume that doesn't exist", ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @lxc.storage.volume.delete 
          pool: 'nikita-storage-get-2'
          name: 'nikita-volume-get-2'
        await @lxc.storage.delete
          name: 'nikita-storage-get-2'
      await @clean()
      await @lxc.storage
        name: 'nikita-storage-get-2'
        driver: "zfs"
      {$status, data} = await @lxc.storage.volume.get
        pool: 'nikita-storage-get-2'
        name: 'nikita-volume-get-2'
      $status.should.be.eql false
      await @clean()
