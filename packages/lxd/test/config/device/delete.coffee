
nikita = require '@nikitajs/engine/lib'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

before ->
  @timeout(-1)
  await nikita.execute "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.config.device.delete', ->

  they 'Fail if the device does not exist', ({ssh}) -> ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      {status} = await @lxd.config.device.delete
        device: 'nondevice'
        container: 'c1'
      status.should.be.false()

  they 'Delete a device', ({ssh}) ->
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
        container: 'c1'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {status} = await @lxd.config.device.delete
        device: 'test'
        container: 'c1'
      status.should.be.true()
