
nikita = require '@nikitajs/engine/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.storage', ->

  they 'Create a storage', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.storage.delete
        name: "teststorage0"
      {status} = await @lxd.storage
        name: "teststorage0"
        driver: "zfs"
      status.should.be.true()

  they 'Different types of config parameters', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.storage.delete
        name: "teststorage0"
      {status} = await @lxd.storage
        name: "teststorage0"
        driver: "zfs"
        properties:
          size: '10GB'
          'zfs.clone_copy': false
      status.should.be.true()

  they 'Storage already created', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.storage.delete
        name: "teststorage0"
      {status} = await @lxd.storage
        name: "teststorage0"
        driver: "zfs"
      status.should.be.true()
      {status} = await @lxd.storage
        name: "teststorage0"
        driver: "zfs"
      status.should.be.false()

  they 'Update storage configuration', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.storage.delete
        name: "teststorage0"
      await @lxd.storage
        name: "teststorage0"
        driver: "zfs"
        properties:
          size: "20GB"
      {status} = await @lxd.storage
        name: "teststorage0"
        driver: "zfs"
        properties:
          size: "10GB"
          'zfs.clone_copy': false
      status.should.be.true()
