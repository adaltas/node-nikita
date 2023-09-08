
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.exists', ->

  they 'argument is a string', ({ssh}) ->
    await nikita.lxc.exists 'nikita-exists-1', ({config}) ->
      config.container.should.eql 'nikita-exists-1'
      
  they 'existing container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-exists-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-exists-2'
      await @lxc.exists 'nikita-exists-2'
      .should.finally.match exists: true
      await @clean()

  they 'missing container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      @lxc.exists 'nikita-exists-3'
      .should.finally.match exists: false
