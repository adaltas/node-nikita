
nikita = require '@nikitajs/engine/lib'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.config.device.exists', ->

  they 'Device does not exist', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'images:alpine/edge'
        container: 'c1'
      {exists} = await @lxd.config.device.exists
        container: 'c1'
        device: 'test'
      exists.should.be.false()

  they 'Device exists', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'images:alpine/edge'
        container: 'c1'
      @lxd.config.device
        container: 'c1'
        device: 'test'
        type: 'unix-char'
        properties:
          source: '/dev/urandom'
          path: '/testrandom'
      {exists} = await @lxd.config.device.exists
        container: 'c1'
        device: 'test'
      exists.should.be.true()
