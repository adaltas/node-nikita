
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita
  .execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.config.device.show', ->

  they 'config output', ({ssh}) ->
    nikita
      ssh: ssh
      # debug: true
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      @lxd.config.device
        container: 'c1'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {status, properties} = await @lxd.config.device.show
        container: 'c1'
        device: 'test'
      status.should.be.true()
      properties.should.eql
        path: '/testrandom'
        source: '/dev/urandom'
        type: 'unix-char'
