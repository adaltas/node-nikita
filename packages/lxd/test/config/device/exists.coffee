
nikita = require '@nikitajs/core'
{tags, ssh, scratch, lxd} = require '../../test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.config.device.exists', ->

  they 'does not exist', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'c1'
    .lxd.config.device.exists
      container: 'c1'
      device: 'test'
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  they 'device exists', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'c1'
    .lxd.config.device
      container: 'c1'
      device: 'test'
      type: 'unix-char'
      config:
        source: '/dev/urandom'
        path: '/testrandom'
    .lxd.config.device.exists
      container: 'c1'
      device: 'test'
    , (err, {status}) ->
      status.should.be.false()
    .promise()
