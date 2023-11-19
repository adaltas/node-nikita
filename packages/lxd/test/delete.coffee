
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.delete', ->
  return unless test.tags.lxd

  they 'Delete a container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-delete-1'
      await @lxc.stop
        container: 'nikita-delete-1'
      {$status} = await @lxc.delete
        container: 'nikita-delete-1'
      $status.should.be.true()
      {$status} = await @lxc.delete
        container: 'nikita-delete-1'
      $status.should.be.false()
  
  they 'Force deletion of a running container', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.init
        image: "images:#{test.images.alpine}"
        container: 'nikita-delete-2'
        start: true
      {$status} = await @lxc.delete
        container: 'nikita-delete-2'
        force: true
      $status.should.be.true()

  they 'Not found', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      await @lxc.delete  # repeated to be sure the container is absent
        container: 'nikita-delete-3'
      {$status} = await @lxc.delete
        container: 'nikita-delete-3'
      $status.should.be.false()
