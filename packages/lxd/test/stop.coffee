
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.stop', ->

  they 'Already stopped', ({ssh})  ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxd.delete 'nikita-stop-1', force: true
      await @clean()
      await @lxd.init
        image: "images:#{images.alpine}"
        container: 'nikita-stop-1'
      {$status} = await @lxd.stop
        container: 'nikita-stop-1'
      $status.should.be.false()
      await @clean()

  they.only 'Stop a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxd.delete 'nikita-stop-2', force: true
      await @clean()
      await @lxd.init
        image: "images:#{images.alpine}"
        container: 'nikita-stop-2'
      await @lxd.start
        container: 'nikita-stop-2'
      {$status} = await @lxd.stop
        container: 'nikita-stop-2'
      $status.should.be.true()
      await @clean()
