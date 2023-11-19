
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.start', ->
  return unless test.tags.lxd

  they 'argument is a string', ({ssh}) ->
    await nikita.lxc.start 'nikita-start-1', ({config}) ->
      config.container.should.eql 'nikita-start-1'

  they 'Start a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-start-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-start-2'
      {$status} = await @lxc.start
        container: 'nikita-start-2'
      $status.should.be.true()
      await @clean()

  they 'Already started', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-start-3', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-start-3'
      await @lxc.start
        container: 'nikita-start-3'
      {$status} = await @lxc.start
        container: 'nikita-start-3'
      $status.should.be.false()
      await @clean()
