
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.stop', ->

  they 'Already stopped', ({ssh})  ->
    nikita
      $ssh: ssh
    , ->
      await @lxd.delete
        container: 'u1'
        force: true
      await @lxd.init
        image: "images:#{images.alpine}"
        container: 'u1'
      {$status} = await @lxd.stop
        container: 'u1'
      $status.should.be.false()

  they 'Stop a container', ({ssh}) ->
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
      {$status} = await @lxd.stop
        container: 'u1'
      $status.should.be.true()
