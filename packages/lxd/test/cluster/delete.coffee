
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)
path = require('path')

return unless tags.lxd

describe 'lxc.cluster.delete', ->

  they 'delete a cluster', ({ssh}) ->
    @timeout -1 # yum install take a lot of time
    nikita
      $ssh: ssh
    , ({registry}) ->
      cluster =
        networks:
          nktlxdpub:
            'ipv4.address': '10.10.40.1/24'
            'ipv4.nat': true
            'ipv6.address': 'none'
        containers:
          'nikita-cluster-del-1':
            image: "images:#{images.alpine}"
            nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
          'nikita-cluster-del-2':
            image: "images:#{images.alpine}"
            nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
      await registry.register 'clean', ->
        # Status modified if cluster deleted
        await @lxc.cluster.delete {...cluster, force: true}
      await registry.register 'test', ->
        await @lxc.cluster cluster
        {list} = await @lxc.list
          filter: 'containers'
        {$status} = await @lxc.cluster.delete {...cluster, force: true}
        $status.should.be.true()
        # Containers and network shall no longer exist
        list.should.not.containEql 'nikita-cluster-del-1'
        list.should.not.containEql 'nikita-cluster-del-2'
        {list} = await @lxc.network.list()
        list.should.not.containEql 'nktlxdpub'
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
            nktlxdpub:
              'ipv4.address': '10.10.40.1/24'
              'ipv4.nat': true
              'ipv6.address': 'none'
          containers:
            'nikita-cluster-del-1':
              image: "images:#{images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
            'nikita-cluster-del-2':
              image: "images:#{images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
        await @lxc.cluster cluster
        await @wait time: 200
        await @lxc.cluster.delete cluster
        .should.be.rejectedWith /^NIKITA_EXECUTE_EXIT_CODE_INVALID:/
        await @lxc.cluster.delete {...cluster, force: true}

    they 'when `true`, force deletion', ({ssh}) ->
      @timeout -1 # yum install take a lot of time
      nikita
        $ssh: ssh
      , ({registry}) ->
        cluster =
          networks:
            nktlxdpub:
              'ipv4.address': '10.10.40.1/24'
              'ipv4.nat': true
              'ipv6.address': 'none'
          containers:
            'nikita-cluster-del-1':
              image: "images:#{images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
            'nikita-cluster-del-2':
              image: "images:#{images.alpine}"
              nic: eth0: name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
        await registry.register 'clean', ->
          await @lxc.cluster.delete
            containers: cluster.containers
            networks: cluster.networks
            force: true
        await registry.register 'test', ->
          await @lxc.cluster cluster
          {$status} = await @lxc.cluster.delete {...cluster, force: true}
          $status.should.be.true()
          {list} = await @lxc.list
            filter: 'containers'
          list.should.not.containEql 'nikita-cluster-del-1'
          list.should.not.containEql 'nikita-cluster-del-2'
          {list} = await @lxc.network.list()
          list.should.not.containEql 'nktlxdpub'
        try 
          await @clean()
          await @test()
        catch err 
          await @clean()
        finally
          await @clean()
