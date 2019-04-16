
nikita = require '@nikitajs/core'
assert = require 'assert'
{tags, ssh, scratch, lxd} = require '../../test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.config.device.add', ->

  they 'fail for invalid device type', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      container: 'c1'
      image: 'ubuntu:16.04'
    .lxd.config.device
      container: 'c1'
      device: 'test'
      type: 'invalid'
      config:
        source: '/dev/urandom'
        target: '/test'
    , (err, {status}) ->
      status.should.be.false()
    .next (err) ->
      err.message.should.equal "Invalid Option: Unrecognized device type: invalid, valid devices are: none, nic, disk, unix-char, unix-block, usb, gpu, infiniband, proxy"
    .promise()

  they 'create device', ({ssh}) ->
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
    , (err, {status}) ->
      status.should.be.true()
    .system.execute
      cmd: "lxc config device list c1 | grep test"
    , (err, {status}) ->
      status.should.be.true()
    .promise()
