
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.storage', ->

  they 'Create a storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxd.storage.delete 'nikita-storage-1'
      await @clean()
      {$status} = await @lxd.storage
        name: "nikita-storage-1"
        driver: "zfs"
      $status.should.be.true()
      await @clean()

  they 'Different types of config parameters', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxd.storage.delete 'nikita-storage-2'
      await @clean()
      {$status} = await @lxd.storage
        name: "nikita-storage-2"
        driver: "zfs"
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
        @lxd.storage.delete 'nikita-storage-3'
      await @clean()
      {$status} = await @lxd.storage
        name: "nikita-storage-3"
        driver: "zfs"
      $status.should.be.true()
      {$status} = await @lxd.storage
        name: "nikita-storage-3"
        driver: "zfs"
      $status.should.be.false()
      await @clean()

  they 'Update storage configuration', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxd.storage.delete 'nikita-storage-4'
      await @clean()
      await @lxd.storage
        name: "nikita-storage-4"
        driver: "zfs"
        properties:
          size: "20GB"
      {$status} = await @lxd.storage
        name: "nikita-storage-4"
        driver: "zfs"
        properties:
          size: "10GB"
          'zfs.clone_copy': false
      $status.should.be.true()
      await @clean()
