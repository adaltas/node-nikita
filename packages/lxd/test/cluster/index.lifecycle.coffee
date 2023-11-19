
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.cluster.lifecycle', ->
  return unless test.tags.lxd
  
  they 'prevision and provision', ({ssh}) ->
    @timeout -1
    nikita
      $ssh: ssh
    , ({registry}) ->
      lifecycle = []
      cluster =
        containers:
          'nikita-cluster-lifecycle-1':
            image: "images:#{test.images.alpine}"
      await registry.register 'clean', ->
        await @lxc.cluster.delete cluster, force: true
      await registry.register 'test', ->
        await @lxc.cluster cluster,
          prevision: ({config}) ->
            lifecycle.push 'prevision'
            config.containers.should.have.property 'nikita-cluster-lifecycle-1'
          prevision_container: ({config}) ->
            lifecycle.push 'prevision_container'
            config.container.should.eql 'nikita-cluster-lifecycle-1'
          provision: ({config}) ->
            lifecycle.push 'provision'
            config.containers.should.have.property 'nikita-cluster-lifecycle-1'
          provision_container: ({config}) ->
            lifecycle.push 'provision_container'
            config.container.should.eql 'nikita-cluster-lifecycle-1'
      try
        await @clean()
        await @test()
        lifecycle.should.eql [
          'prevision'
          'prevision_container'
          'provision_container'
          'provision'
        ]
      finally
        await @clean()
