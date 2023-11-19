
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.exists', ->
  return unless test.tags.lxd

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
        image: "images:#{test.images.alpine}"
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
