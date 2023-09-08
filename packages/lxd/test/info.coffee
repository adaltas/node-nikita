
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require './test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxc.info', ->

  they 'argument is a string', ({ssh}) ->
    await nikita.lxc.info 'nikita-info-1', ({config}) ->
      config.container.should.eql 'nikita-info-1'
      
  they 'existing container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-info-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{images.alpine}"
        container: 'nikita-info-2'
      await @lxc.info 'nikita-info-2'
      .should.finally.match data: name: 'nikita-info-2'
      await @clean()
