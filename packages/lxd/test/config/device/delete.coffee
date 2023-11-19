
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.config.device.delete', ->
  return unless test.tags.lxd

  they 'Fail if the device does not exist', ({ssh}) -> ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-config-device-delete-1'
        force: true
      @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-device-delete-1'
      {$status} = await @lxc.config.device.delete
        device: 'nondevice'
        container: 'nikita-config-device-delete-1'
      $status.should.be.false()

  they 'Delete a device', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-config-device-delete-2'
        force: true
      @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-device-delete-2'
      @lxc.config.device
        container: 'nikita-config-device-delete-2'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {$status} = await @lxc.config.device.delete
        device: 'test'
        container: 'nikita-config-device-delete-2'
      $status.should.be.true()
