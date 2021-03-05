
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.start', ->

  they 'Start a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxd.delete
        container: 'u1'
        force: true
      await @lxd.init
        image: "images:#{images.alpine}"
        container: 'u1'
      {$status} = await @lxd.start
        container: 'u1'
      $status.should.be.true()

  they 'Already started', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxd.delete
        container: 'u1'
        force: true
      await @lxd.init
        image: "images:#{images.alpine}"
        container: 'u1'
      await @lxd.start
        container: 'u1'
      {$status} = await @lxd.start
        container: 'u1'
      $status.should.be.false()
