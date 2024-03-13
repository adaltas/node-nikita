
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.cluster.stop', ->
  return unless test.tags.incus

  they 'stop a running cluster', ({ssh}) ->
    @timeout -1 # yum install take a lot of time
    cluster =
      networks:
        nktincuspub:
          'ipv4.address': '10.10.40.1/24'
          'ipv4.nat': true
          'ipv6.address': 'none'
      containers:
        'nikita-cluster-stop-1':
          image: "images:#{test.images.alpine}"
          nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
        'nikita-cluster-stop-2':
          image: "images:#{test.images.alpine}"
          nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
    nikita
      $ssh: ssh
    , ({registry}) ->
      await registry.register ['clean'], ->
        await @incus.cluster.delete {...cluster, force: true}
      await @clean()
      await @incus.cluster cluster
      await @wait time: 200
      {$status} = await @incus.cluster.stop {...cluster, wait: true}
      $status.should.be.true()
      {config} = await @incus.state
        container: 'nikita-cluster-stop-1'
      config.status.should.eql 'Stopped'
      {config} = await @incus.state
        container: 'nikita-cluster-stop-2'
      config.status.should.eql 'Stopped'
      await @clean()
