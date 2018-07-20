
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.info.disks', ->

  config = test.config()
  return if config.disable_system_info

  they 'with handler options', (ssh) ->
    nikita
      ssh: ssh
    .system.info.disks (err, {status, disks}) ->
      throw err if err
      status.should.be.false()
      disks.length.should.be.above 0
      for disk in disks
        Object.keys(disk).should.eql [
          'filesystem', 'total', 'used',
          'available', 'available_pourcent', 'mountpoint'
        ]
    .promise()
