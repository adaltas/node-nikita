
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.start', ->

  they 'Start a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxd.delete 'nikita-start-1', force: true
      await @clean()
      await @lxd.delete
        container: 'nikita-start-1'
        force: true
      await @lxd.init
        image: "images:#{images.alpine}"
        container: 'nikita-start-1'
      {$status} = await @lxd.start
        container: 'nikita-start-1'
      $status.should.be.true()
      await @clean()

  they 'Already started', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxd.delete 'nikita-start-2', force: true
      await @clean()
      await @lxd.init
        image: "images:#{images.alpine}"
        container: 'nikita-start-2'
      await @lxd.start
        container: 'nikita-start-2'
      {$status} = await @lxd.start
        container: 'nikita-start-2'
      $status.should.be.false()
      await @clean()
