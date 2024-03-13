
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.storage', ->
  return unless test.tags.incus

  they 'Create a storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.storage.delete 'nikita-storage-1'
      await @clean()
      {$status} = await @incus.storage
        name: 'nikita-storage-1'
        driver: 'zfs'
      $status.should.be.true()
      await @clean()

  they 'Different types of config parameters', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.storage.delete 'nikita-storage-2'
      await @clean()
      {$status} = await @incus.storage
        name: 'nikita-storage-2'
        driver: 'zfs'
        properties:
          size: '10GB'
          'zfs.clone_copy': false
      $status.should.be.true()
      await @clean()

  they 'Storage already created', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.storage.delete 'nikita-storage-3'
      await @clean()
      {$status} = await @incus.storage
        name: 'nikita-storage-3'
        driver: 'zfs'
      $status.should.be.true()
      {$status} = await @incus.storage
        name: 'nikita-storage-3'
        driver: 'zfs'
      $status.should.be.false()
      await @clean()

  they 'Update storage configuration', ({ssh}) ->
    # Note, storage is set to expand and not to shrink. With the later,
    # some configurations fail with the error "Pool cannot be shrunk".
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.storage.delete 'nikita-storage-4'
      await @clean()
      await @incus.storage
        name: 'nikita-storage-4'
        driver: 'zfs'
        properties:
          size: '10GB'
      {$status} = await @incus.storage
        name: 'nikita-storage-4'
        driver: 'zfs'
        properties:
          size: '20GB'
          'zfs.clone_copy': false
      $status.should.be.true()
      await @clean()
