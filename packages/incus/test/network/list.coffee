
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.network.list', ->
  return unless test.tags.incus

  they 'list all networks', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        await @incus.network.delete
          name: 'nkttestnetlist'
      registry.register 'test', ->
        await @incus.network
          name: 'nkttestnetlist'
          properties:
            'ipv4.address': '192.0.2.1/30'
            'dns.domain': 'nikita.net.test'
        await @incus.network.list()
          .then ({$status, networks}) =>
            $status.should.be.true()
            networks.map( (network) => network.name).should.containEql 'nkttestnetlist'
      try
        await @clean()
        await @test()
      finally
        await @clean()
