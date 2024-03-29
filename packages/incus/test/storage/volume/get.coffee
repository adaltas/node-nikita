import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.storage.volume.get', ->
  return unless test.tags.incus

  they 'get a volume', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @incus.storage.volume.delete 
          pool: 'nikita-storage-get-1'
          name: 'nikita-volume-get-1'
        await @incus.storage.delete
          name: 'nikita-storage-get-1'
      await @clean()
      await @incus.storage
        name: 'nikita-storage-get-1'
        driver: "zfs"
      await @incus.storage.volume
        name: 'nikita-volume-get-1'
        pool: 'nikita-storage-get-1'
      {$status, data} = await @incus.storage.volume.get
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
        await @incus.storage.volume.delete 
          pool: 'nikita-storage-get-2'
          name: 'nikita-volume-get-2'
        await @incus.storage.delete
          name: 'nikita-storage-get-2'
      await @clean()
      await @incus.storage
        name: 'nikita-storage-get-2'
        driver: "zfs"
      {$status, data} = await @incus.storage.volume.get
        pool: 'nikita-storage-get-2'
        name: 'nikita-volume-get-2'
      $status.should.be.eql false
      await @clean()
