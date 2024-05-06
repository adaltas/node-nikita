import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.storage.volume.attach', ->
  return unless test.tags.incus

  describe 'attach', ->

    they 'should attach a volume', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete
            container: 'nikita-container-attach-1'
          await @incus.storage.volume.delete 
            pool: 'nikita-storage-attach-1'
            name: 'nikita-volume-attach-1'
          await @incus.storage.delete
            name: 'nikita-storage-attach-1'
        await @clean()
        # Create storage and volume
        await @incus.storage
          name: 'nikita-storage-attach-1'
          driver: "zfs"
        await @incus.storage.volume
          name: 'nikita-volume-attach-1'
          pool: 'nikita-storage-attach-1' 
        # Create instance 
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-container-attach-1'
        # Attach volume to instance
        {$status} = await @incus.storage.volume.attach
          pool: 'nikita-storage-attach-1'
          name: 'nikita-volume-attach-1'
          container: 'nikita-container-attach-1'
          device: 'osd'
          path: '/osd/'
        $status.should.be.eql true
        # Check if volume is attached
        {$status, data} = await @incus.query
          path: '/1.0/instances/nikita-container-attach-1'
        $status.should.be.eql true
        data.devices.should.containEql {'osd': {type: 'disk', source: 'nikita-volume-attach-1', pool: 'nikita-storage-attach-1', path: '/osd/'}}
        await @clean()

    return unless test.tags.incus_vm
    
    they 'should attach a block volume on a vm', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete
            container: 'nikita-container-attach-2'
          await @incus.storage.volume.delete 
            pool: 'nikita-storage-attach-2'
            name: 'nikita-volume-attach-2'
          await @incus.storage.delete
            name: 'nikita-storage-attach-2'
        await @clean()
        # Create storage and volume
        await @incus.storage
          name: 'nikita-storage-attach-2'
          driver: "zfs"
        await @incus.storage.volume
          name: 'nikita-volume-attach-2'
          pool: 'nikita-storage-attach-2' 
          content: 'block'
        # Create instance 
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-container-attach-2'
          vm:true
        # Attach volume to instance
        {$status} = await @incus.storage.volume.attach
          pool: 'nikita-storage-attach-2'
          name: 'nikita-volume-attach-2'
          container: 'nikita-container-attach-2'
          device: 'osd'
        $status.should.be.eql true
        # Check if volume is attached
        {$status, data} = await @incus.query
          path: '/1.0/instances/nikita-container-attach-2'
        $status.should.be.eql true
        data.devices.should.containEql {'osd': {type: 'disk', source: 'nikita-volume-attach-2', pool: 'nikita-storage-attach-2'}}
        await @clean()

  describe 'rejection', ->

    they "did not specify the path with filesystem", ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete
            container: 'nikita-container-attach-1'
          await @incus.storage.volume.delete 
            pool: 'nikita-storage-attach-1'
            name: 'nikita-volume-attach-1'
          await @incus.storage.delete
            name: 'nikita-storage-attach-1'
        await @clean()
        # Create storage and volume
        await @incus.storage
          name: 'nikita-storage-attach-1'
          driver: "zfs"
        await @incus.storage.volume
          name: 'nikita-volume-attach-1'
          pool: 'nikita-storage-attach-1' 
        # Create instance 
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-container-attach-1'
        # Attach volume to instance
        await @incus.storage.volume.attach
          pool: 'nikita-storage-attach-1'
          name: 'nikita-volume-attach-1'
          container: 'nikita-container-attach-1'
          device: 'osd'
        .should.be.rejectedWith /^Missing requirement: Path is required for filesystem type volumes./
        await @clean()

    return unless test.tags.incus_vm

    they 'should attach a filesystem to a vm', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete
            container: 'nikita-container-attach-2'
          await @incus.storage.volume.delete 
            pool: 'nikita-storage-attach-2'
            name: 'nikita-volume-attach-2'
          await @incus.storage.delete
            name: 'nikita-storage-attach-2'
        await @clean()
        # Create storage and volume
        await @incus.storage
          name: 'nikita-storage-attach-2'
          driver: "zfs"
        await @incus.storage.volume
          name: 'nikita-volume-attach-2'
          pool: 'nikita-storage-attach-2' 
        # Create instance 
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-container-attach-2'
          vm: true
        # Attach volume to instance
        await @incus.storage.volume.attach
          pool: 'nikita-storage-attach-2'
          name: 'nikita-volume-attach-2'
          container: 'nikita-container-attach-2'
          device: 'osd'
          path: '/osd/'
        .should.be.rejectedWith /^Type: virtual-machine can only mount block type volumes./
        await @clean()

    they 'should attach a block volume to a container', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete
            container: 'nikita-container-attach-3'
          await @incus.storage.volume.delete 
            pool: 'nikita-storage-attach-3'
            name: 'nikita-volume-attach-3'
          await @incus.storage.delete
            name: 'nikita-storage-attach-3'
        await @clean()
        # Create storage and volume
        await @incus.storage
          name: 'nikita-storage-attach-3'
          driver: "zfs"
        await @incus.storage.volume
          name: 'nikita-volume-attach-3'
          pool: 'nikita-storage-attach-3'
          content: 'block'
        # Create instance 
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-container-attach-3'
        # Attach volume to instance
        await @incus.storage.volume.attach
          pool: 'nikita-storage-attach-3'
          name: 'nikita-volume-attach-3'
          container: 'nikita-container-attach-3'
          device: 'osd'
          path: '/osd/'
        .should.be.rejectedWith /^Type: container can only mount filesystem type volumes./
        await @clean()

    they 'should forget the volume', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete
            container: 'nikita-container-attach-4'
          await @incus.storage.volume.delete 
            pool: 'nikita-storage-attach-4'
            name: 'nikita-volume-attach-4'
          await @incus.storage.delete
            name: 'nikita-storage-attach-4'
        await @clean()
        # Create storage and volume
        await @incus.storage
          name: 'nikita-storage-attach-4'
          driver: "zfs"
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-container-attach-4'
        # Attach volume to instance
        await @incus.storage.volume.attach
          pool: 'nikita-storage-attach-4'
          name: 'nikita-volume-attach-4'
          container: 'nikita-container-attach-4'
          device: 'osd'
          path: '/osd/'
        .should.be.rejectedWith 'NIKITA_INCUS_VOLUME_ATTACH: volume "nikita-volume-attach-4" does not exist.'
        await @clean()

    they 'should forget the container', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete
            container: 'nikita-container-attach-5'
          await @incus.storage.volume.delete 
            pool: 'nikita-storage-attach-5'
            name: 'nikita-volume-attach-5'
          await @incus.storage.delete
            name: 'nikita-storage-attach-5'
        await @clean()
        # Create storage and volume
        await @incus.storage
          name: 'nikita-storage-attach-5'
          driver: "zfs"
        await @incus.storage.volume
          name: 'nikita-volume-attach-5'
          pool: 'nikita-storage-attach-5'
        # Attach volume to instance
        await @incus.storage.volume.attach
          pool: 'nikita-storage-attach-5'
          name: 'nikita-volume-attach-5'
          container: 'nikita-container-attach-5'
          device: 'osd'
          path: '/osd/'
        .should.be.rejectedWith 'NIKITA_INCUS_VOLUME_ATTACH: container "nikita-container-attach-5" does not exist.'
        await @clean()
