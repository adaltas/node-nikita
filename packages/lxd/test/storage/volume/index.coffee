import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.storage.volume', ->
  return unless test.tags.lxd

  describe 'volume creation', ->

    they 'create a volume', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @lxc.storage.volume.delete 
            pool: 'nikita-storage-create-1'
            name: 'nikita-volume-create-1'
          await @lxc.storage.delete
            name: 'nikita-storage-create-1'
        await @clean()
        await @lxc.storage
          name: 'nikita-storage-create-1'
          driver: "zfs"
        {$status} = await @lxc.storage.volume
          name: 'nikita-volume-create-1'
          pool: 'nikita-storage-create-1'
        $status.should.be.eql true
        await @clean()
    
    they 'create a volume in a non-existing pool', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @lxc.storage.volume.delete 
            pool: 'nikita-storage-create-2'
            name: 'nikita-volume-create-2'
          await @lxc.storage.delete
            name: 'nikita-storage-create-2'
        await @clean()
        {$status} = await @lxc.storage.volume
          name: 'nikita-volume-create-2'
          pool: 'nikita-storage-create-2'
        $status.should.be.eql false
        await @clean()
    
    they 'create two times the same volume', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @lxc.storage.volume.delete 
            pool: 'nikita-storage-create-3'
            name: 'nikita-volume-create-3'
          await @lxc.storage.delete
            name: 'nikita-storage-create-3'
        await @clean()
        await @lxc.storage
          name: 'nikita-storage-create-3'
          driver: "zfs"
        {$status} = await @lxc.storage.volume
          name: 'nikita-volume-create-3'
          pool: 'nikita-storage-create-3'
        $status.should.be.eql true
        {$status} = await @lxc.storage.volume
          name: 'nikita-volume-create-3'
          pool: 'nikita-storage-create-3'
        $status.should.be.eql false
        await @clean()

  describe 'volume configuration', ->

    they 'create a volume with config', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @lxc.storage.volume.delete 
            pool: 'nikita-storage-config-1'
            name: 'nikita-volume-config-1'
          await @lxc.storage.delete
            name: 'nikita-storage-config-1'
        await @clean()
        await @lxc.storage
          name: 'nikita-storage-config-1'
          driver: "zfs"
        await @lxc.storage.volume
          name: 'nikita-volume-config-1'
          pool: 'nikita-storage-config-1'
          properties:
            size: '10GB'
        {data} = await @lxc.storage.volume.get
          pool: 'nikita-storage-config-1'
          name: 'nikita-volume-config-1'
        data.config.size.should.be.eql '10GB'
        await @clean()

    they 'create a volume with wrong config', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @lxc.storage.volume.delete 
            pool: 'nikita-storage-config-2'
            name: 'nikita-volume-config-2'
          await @lxc.storage.delete
            name: 'nikita-storage-config-2'
        await @clean()
        await @lxc.storage
          name: 'nikita-storage-config-2'
          driver: "zfs"
        {$status} = await @lxc.storage.volume
          name: 'nikita-volume-config-2'
          pool: 'nikita-storage-config-2'
          properties:
            size: '10gb'
        $status.should.be.eql false
        await @clean()

    they 'create a volume filesystem', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @lxc.storage.volume.delete 
            pool: 'nikita-storage-config-3'
            name: 'nikita-volume-config-3'
          await @lxc.storage.delete
            name: 'nikita-storage-config-3'
        await @clean()
        await @lxc.storage
          name: 'nikita-storage-config-3'
          driver: "zfs"
        await @lxc.storage.volume
          name: 'nikita-volume-config-3'
          pool: 'nikita-storage-config-3'
          content: 'block'
        {data} = await @lxc.storage.volume.get
          pool: 'nikita-storage-config-3'
          name: 'nikita-volume-config-3'
        data.content_type.should.be.eql 'block'
        await @clean()  
