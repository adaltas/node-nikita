
nikita = require '@nikitajs/core'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh...

return unless tags.lxd

describe 'lxd.config.device.show', ->

  they 'config output', ({ssh}) ->
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
    .lxd.config.device.show
      container: 'c1'
      device: 'test'
    , (err, {status, config}) ->
      status.should.be.true()
      config.should.eql
        path: '/testrandom'
        source: '/dev/urandom'
        type: 'unix-char'
    .promise()
