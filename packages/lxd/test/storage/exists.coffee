
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.storage.exists', ->

  they 'argument is a string', ({ssh}) ->
    await nikita.lxc.storage.exists 'nikita-storage-exists-1', ({config}) ->
      config.name.should.eql 'nikita-storage-exists-1'

  they 'with existing storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.storage
        name: 'nikita-storage-exists-2'
        driver: "zfs"
      {exists} = await @lxc.storage.exists 'nikita-storage-exists-2'
      exists.should.be.true()
      await @lxc.storage.delete 'nikita-storage-exists-2'

  they 'with missing storage', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {exists} = await @lxc.storage.exists 'nikita-storage-exists-3'
      exists.should.be.false()
      
