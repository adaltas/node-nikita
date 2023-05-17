
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)
path = require('path')

return unless tags.lxd

describe 'lxc.cluster.lifecycle', ->
  
  they 'prevision and provision', ({ssh}) ->
    @timeout -1
    nikita
      $ssh: ssh
    , ({registry}) ->
      lifecycle = []
      cluster =
        containers:
          'nikita-cluster-lifecycle-1':
            image: "images:#{images.alpine}"
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
