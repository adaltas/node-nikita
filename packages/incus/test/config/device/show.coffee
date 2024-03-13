
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.config.device.show', ->
  return unless test.tags.incus

  they 'config output', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.delete
        container: 'nikita-config-show-1'
        force: true
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-show-1'
      await @incus.config.device
        container: 'nikita-config-show-1'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {$status, properties} = await @incus.config.device.show
        container: 'nikita-config-show-1'
        device: 'test'
      $status.should.be.true()
      properties.should.eql
        path: '/testrandom'
        source: '/dev/urandom'
        type: 'unix-char'
