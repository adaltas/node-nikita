
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.state', ->
  return unless test.tags.lxd

  they 'argument is a string', ({ssh}) ->
    await nikita.lxc.state 'nikita-state-1', ({config}) ->
      config.container.should.eql 'nikita-state-1'
      
  they 'Show instance state', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-state-2', force: true
      await @clean()
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-state-2'
      {$status, config} = await @lxc.state
        container: 'nikita-state-2'
      $status.should.be.true()
      config.status.should.eql 'Stopped'
      await @clean()

  they 'Instance not found', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-state-3', force: true
      await @clean()
      await @lxc.state
        container: 'nikita-state-3'
      .should.be.rejectedWith
        exit_code: 1
      await @clean()
