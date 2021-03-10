
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.config.device.exists', ->

  they 'Device does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @lxc.delete
        container: 'c1'
        force: true
      @lxc.init
        image: "images:#{images.alpine}"
        container: 'c1'
      {exists} = await @lxc.config.device.exists
        container: 'c1'
        device: 'test'
      exists.should.be.false()

  they 'Device exists', ({ssh}) ->
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
      {exists} = await @lxc.config.device.exists
        container: 'c1'
        device: 'test'
      exists.should.be.true()
