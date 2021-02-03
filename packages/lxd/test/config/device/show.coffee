
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.config.device.show', ->

  they 'config output', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: "images:#{images.alpine}"
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
