
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.info', ->
  return unless test.tags.lxd

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
        image: "images:#{test.images.alpine}"
        container: 'nikita-info-2'
      await @lxc.info 'nikita-info-2'
      .should.finally.match data: name: 'nikita-info-2'
      await @clean()
