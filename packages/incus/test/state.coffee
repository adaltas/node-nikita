
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.state', ->
  return unless test.tags.incus

  they 'argument is a string', ({ssh}) ->
    await nikita.incus.state 'nikita-state-1', ({config}) ->
      config.container.should.eql 'nikita-state-1'
      
  they 'Show instance state', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-state-2', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-state-2'
      {$status, config} = await @incus.state
        container: 'nikita-state-2'
      $status.should.be.true()
      config.status.should.eql 'Stopped'
      await @clean()

  they 'Instance not found', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-state-3', force: true
      await @clean()
      await @incus.state
        container: 'nikita-state-3'
      .should.be.rejectedWith
        exit_code: 1
      await @clean()
