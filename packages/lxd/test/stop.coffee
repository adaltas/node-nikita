
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.stop', ->
  return unless test.tags.lxd

  they 'argument is a string', ({ssh}) ->
    await nikita.lxc.stop 'nikita-stop-1', ({config}) ->
      config.container.should.eql 'nikita-stop-1'

  they 'Already stopped', ({ssh})  ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-stop-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-stop-2'
      {$status} = await @lxc.stop
        container: 'nikita-stop-2'
      $status.should.be.false()
      await @clean()

  they 'Stop a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-stop-3', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-stop-3'
        start: true
      {$status} = await @lxc.stop
        container: 'nikita-stop-3'
      $status.should.be.true()
      await @clean()
