
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

describe 'lxd.config.device.delete', ->
  they 'fail if the device does not exist', ({ssh}) -> ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'c1'
    .lxd.config.device.delete
      device: 'nondevice'
      container: 'c1'
    , (err, {status}) ->
      err.should.be.null()
      status.should.be.false()
    .promise()

  they 'delete a device', ({ssh}) ->
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
    .lxd.config.device.delete
      device: 'test'
      container: 'c1'
    , (err, {status}) ->
      status.should.be.true()
    .promise()
