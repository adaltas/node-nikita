
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.running', ->
  return unless test.tags.lxd

  they 'argument is a string', ({ssh}) ->
    await nikita.lxc.running 'nikita-running-1', ({config}) ->
      config.container.should.eql 'nikita-running-1'

  they 'Running container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-running-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-running-2'
        start: true
      {$status} = await @lxc.running
        container: 'nikita-running-2'
      $status.should.be.true()
      await @clean()

  they 'Stopped container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-running-3', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-running-3'
      {$status} = await @lxc.running
        container: 'nikita-running-3'
      $status.should.be.false()
      await @clean()
