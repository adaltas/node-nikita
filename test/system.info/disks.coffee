
nikita = require '../../src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.system_info

describe 'system.info.disks', ->

  they 'with no options', (ssh) ->
    nikita
      ssh: ssh
    .system.info.disks (err, {status, disks}) ->
      throw err if err
      status.should.be.false()
      disks.length.should.be.above 0
      for disk in disks
        Object.keys(disk).should.eql [
          'df', 'filesystem', 'total', 'used',
          'available', 'available_pourcent', 'mountpoint'
        ]
        Object.keys(disk.df).should.eql [
          'source', 'fstype', 'itotal', 'iused',
          'iavail', 'ipcent', 'size', 'used', 'avail',
          'pcent', 'target'
        ]
    .promise()
