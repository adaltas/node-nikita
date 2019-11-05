
nikita = require '@nikitajs/core'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.config.device.set', ->

  they 'same configuration', ({ssh}) ->
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
    .lxd.config.device
      container: 'c1'
      device: 'test'
      type: 'unix-char'
      config:
        source: '/dev/urandom'
        path: '/testrandom'
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  they 'change device configuration', ({ssh}) ->
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
    .lxd.config.device
      container: 'c1'
      device: 'test'
      config:
        source: '/dev/null'
    , (err, {status}) ->
      status.should.be.true()
    .system.execute
      cmd: "lxc config device show c1 | grep 'source: /dev/null'"
    , (err, {status, stdout}) ->
      status.should.be.true()
    .promise()
