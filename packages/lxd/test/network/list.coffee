
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.network.list', ->
  return unless test.tags.lxd

  they 'list all networks', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @lxc.network.delete
          network: 'nkttestnetlist'
      registry.register 'test', ->
        await @lxc.network
          network: 'nkttestnetlist'
          properties:
            'ipv4.address': '192.0.2.1/30'
            'dns.domain': 'nikita.net.test'
        {$status, list} = await @lxc.network.list()
        $status.should.be.true()
        list.should.containEql 'nkttestnetlist'
      try 
        await @clean()
        await @test()
      finally 
        await @clean()
