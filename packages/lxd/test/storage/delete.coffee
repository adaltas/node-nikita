
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

describe 'lxd.storage.delete', ->

  they 'Delete a storage', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.storage
        name: "teststorage0"
        driver: "zfs"
      {status} = await @lxd.storage.delete
        name: "teststorage0"
      status.should.be.true()
      
  they 'Storage already deleted', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      await @lxd.storage
        name: "teststorage0"
        driver: "zfs"
      await @lxd.storage.delete
        name: "teststorage0"
      {status} = await @lxd.storage.delete
        name: "teststorage0"
      status.should.be.false()
  
