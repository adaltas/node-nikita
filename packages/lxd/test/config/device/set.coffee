
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

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

  they 'catch and format error', ({ssh}) ->
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
      device: 'vpn'
      type: 'proxy'
      config:
        listen: 'udp:127.0.0.1:1195'
        connect: 'udp:127.0.0.1:1194'
    .lxd.config.device
      container: 'c1'
      device: 'vpn'
      type: 'proxy'
      config:
        listen: 'udp:127.0.0.1:1195'
        connect: 'udp:127.0.0.999:1194'
      relax: true
    , (err) ->
      err.message.should.eql 'Error: Invalid devices: Invalid value for device option connect: Not an IP address: 127.0.0.999'
    .promise()
