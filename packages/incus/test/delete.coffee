
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.delete', ->
  return unless test.tags.incus

  they 'Delete a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-delete-1'
      await @incus.stop
        container: 'nikita-delete-1'
      {$status} = await @incus.delete
        container: 'nikita-delete-1'
      $status.should.be.true()
      {$status} = await @incus.delete
        container: 'nikita-delete-1'
      $status.should.be.false()
  
  they 'Force deletion of a running container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-delete-2'
        start: true
      {$status} = await @incus.delete
        container: 'nikita-delete-2'
        force: true
      $status.should.be.true()

  they 'Not found', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @incus.delete  # repeated to be sure the container is absent
        container: 'nikita-delete-3'
      {$status} = await @incus.delete
        container: 'nikita-delete-3'
      $status.should.be.false()
