
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.stop', ->
  return unless test.tags.incus

  they 'argument is a string', ({ssh}) ->
    await nikita.incus.stop 'nikita-stop-1', ({config}) ->
      config.container.should.eql 'nikita-stop-1'

  they 'Already stopped', ({ssh})  ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-stop-2', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-stop-2'
      {$status} = await @incus.stop
        container: 'nikita-stop-2'
      $status.should.be.false()
      await @clean()

  they 'Stop a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-stop-3', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-stop-3'
        start: true
      {$status} = await @incus.stop
        container: 'nikita-stop-3'
      $status.should.be.true()
      await @clean()
