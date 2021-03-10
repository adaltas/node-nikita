
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.config.device.delete', ->

  they 'Fail if the device does not exist', ({ssh}) -> ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'c1'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'c1'
      {$status} = await @lxc.config.device.delete
        device: 'nondevice'
        container: 'c1'
      $status.should.be.false()

  they 'Delete a device', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'c1'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'c1'
      @lxc.config.device
        container: 'c1'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {$status} = await @lxc.config.device.delete
        device: 'test'
        container: 'c1'
      $status.should.be.true()
