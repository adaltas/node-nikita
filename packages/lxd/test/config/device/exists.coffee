
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.config.device.exists', ->
  return unless test.tags.lxd

  they 'Device does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.delete
        container: 'nikita-config-device-exists-1'
        force: true
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-device-exists-1'
      {exists} = await @lxc.config.device.exists
        container: 'nikita-config-device-exists-1'
        device: 'test'
      exists.should.be.false()

  they 'Device exists', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.delete
        container: 'nikita-config-device-exists-2'
        force: true
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-device-exists-2'
      await @lxc.config.device
        container: 'nikita-config-device-exists-2'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {exists} = await @lxc.config.device.exists
        container: 'nikita-config-device-exists-2'
        device: 'test'
      exists.should.be.true()
