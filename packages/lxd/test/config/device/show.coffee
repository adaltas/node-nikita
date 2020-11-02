
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before () ->
  await nikita
  .execute
    cmd: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.config.device.show', ->

  they 'config output', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      @lxd.config.device
        config:
          container: 'c1'
          device: 'test'
          type: 'unix-char'
          config:
            source: '/dev/urandom'
            path: '/testrandom'
      {status, config} = await @lxd.config.device.show
        container: 'c1'
        device: 'test'
      status.should.be.true()
      config.should.eql
        path: '/testrandom'
        source: '/dev/urandom'
        type: 'unix-char'
