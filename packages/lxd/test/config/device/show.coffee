
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.config.device.show', ->
  return unless test.tags.lxd

  they 'config output', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'nikita-config-show-1'
        force: true
      @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-config-show-1'
      @lxc.config.device
        container: 'nikita-config-show-1'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {$status, properties} = await @lxc.config.device.show
        container: 'nikita-config-show-1'
        device: 'test'
      $status.should.be.true()
      properties.should.eql
        path: '/testrandom'
        source: '/dev/urandom'
        type: 'unix-char'
