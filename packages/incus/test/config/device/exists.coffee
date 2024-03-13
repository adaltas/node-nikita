
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.config.device.exists', ->
  return unless test.tags.incus

  they 'Device does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.delete
        container: 'nikita-config-device-exists-1'
        force: true
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-device-exists-1'
      {exists} = await @incus.config.device.exists
        container: 'nikita-config-device-exists-1'
        device: 'test'
      exists.should.be.false()

  they 'Device exists', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.delete
        container: 'nikita-config-device-exists-2'
        force: true
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-device-exists-2'
      await @incus.config.device
        container: 'nikita-config-device-exists-2'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {exists} = await @incus.config.device.exists
        container: 'nikita-config-device-exists-2'
        device: 'test'
      exists.should.be.true()
