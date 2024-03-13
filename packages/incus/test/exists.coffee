
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.exists', ->
  return unless test.tags.incus

  they 'argument is a string', ({ssh}) ->
    await nikita.incus.exists 'nikita-exists-1', ({config}) ->
      config.container.should.eql 'nikita-exists-1'
      
  they 'existing container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-exists-2', force: true
      await @clean()
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-exists-2'
      await @incus.exists 'nikita-exists-2'
      .should.finally.match exists: true
      await @clean()

  they 'missing container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      @incus.exists 'nikita-exists-3'
      .should.finally.match exists: false
