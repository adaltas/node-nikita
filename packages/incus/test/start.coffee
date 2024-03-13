
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.start', ->
  return unless test.tags.incus

  they 'argument is a string', ({ssh}) ->
    await nikita.incus.start 'nikita-start-1', ({config}) ->
      config.container.should.eql 'nikita-start-1'

  they 'Start a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-start-2', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-start-2'
      {$status} = await @incus.start
        container: 'nikita-start-2'
      $status.should.be.true()
      await @clean()

  they 'Already started', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-start-3', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-start-3'
      await @incus.start
        container: 'nikita-start-3'
      {$status} = await @incus.start
        container: 'nikita-start-3'
      $status.should.be.false()
      await @clean()
