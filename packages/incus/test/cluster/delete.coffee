
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.cluster.delete', ->
  return unless test.tags.incus

  they 'delete a cluster', ({ssh}) ->
    @timeout -1 # yum install take a lot of time
    nikita
      $ssh: ssh
    , ({registry}) ->
      cluster =
        networks:
          nktincuspub:
            'ipv4.address': '10.10.40.1/24'
            'ipv4.nat': true
            'ipv6.address': 'none'
        containers:
          'nikita-cluster-del-1':
            image: "images:#{test.images.alpine}"
            nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
          'nikita-cluster-del-2':
            image: "images:#{test.images.alpine}"
            nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
      await registry.register 'clean', ->
        # Status modified if cluster deleted
        await @incus.cluster.delete {...cluster, force: true}
      await registry.register 'test', ->
        await @incus.cluster cluster
        {list} = await @incus.list
          filter: 'containers'
        {$status} = await @incus.cluster.delete {...cluster, force: true}
        $status.should.be.true()
        # Containers and network shall no longer exist
        list.should.not.containEql 'nikita-cluster-del-1'
        list.should.not.containEql 'nikita-cluster-del-2'
        {list} = await @incus.network.list()
        list.should.not.containEql 'nktincuspub'
      try 
        await @test()
      catch err 
        await @clean()
      finally
        await @clean()
  
  describe 'option `force`', ->

    they 'when `false`, generate an error if cluster is running', ({ssh}) ->
      @timeout -1 # yum install take a lot of time
      nikita
        $ssh: ssh
      , ->
        cluster =
          networks:
            nktincuspub:
              'ipv4.address': '10.10.40.1/24'
              'ipv4.nat': true
              'ipv6.address': 'none'
          containers:
            'nikita-cluster-del-1':
              image: "images:#{test.images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
            'nikita-cluster-del-2':
              image: "images:#{test.images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
        await @incus.cluster cluster
        await @wait time: 200
        await @incus.cluster.delete cluster
        .should.be.rejectedWith /^NIKITA_EXECUTE_EXIT_CODE_INVALID:/
        await @incus.cluster.delete {...cluster, force: true}

    they 'when `true`, force deletion', ({ssh}) ->
      @timeout -1 # yum install take a lot of time
      nikita
        $ssh: ssh
      , ({registry}) ->
        cluster =
          networks:
            nktincuspub:
              'ipv4.address': '10.10.40.1/24'
              'ipv4.nat': true
              'ipv6.address': 'none'
          containers:
            'nikita-cluster-del-1':
              image: "images:#{test.images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
            'nikita-cluster-del-2':
              image: "images:#{test.images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
        await registry.register 'clean', ->
          await @incus.cluster.delete
            containers: cluster.containers
            networks: cluster.networks
            force: true
        await registry.register 'test', ->
          await @incus.cluster cluster
          {$status} = await @incus.cluster.delete {...cluster, force: true}
          $status.should.be.true()
          {list} = await @incus.list
            filter: 'containers'
          list.should.not.containEql 'nikita-cluster-del-1'
          list.should.not.containEql 'nikita-cluster-del-2'
          {list} = await @incus.network.list()
          list.should.not.containEql 'nktincuspub'
        try 
          await @clean()
          await @test()
        catch err 
          await @clean()
        finally
          await @clean()
