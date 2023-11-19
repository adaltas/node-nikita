
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'ipa.service.show', ->
  return unless test.tags.ipa

  they 'get single service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      {result} = await @ipa.service.show connection: test.ipa,
        principal: 'HTTP/ipa.nikita.local'
      result.dn.should.eql 'krbprincipalname=HTTP/ipa.nikita.local@NIKITA.LOCAL,cn=services,cn=accounts,dc=nikita,dc=local'

  they 'get missing service', ({ssh}) ->
    nikita
      $ssh: ssh
    , ->
      @ipa.service.show connection: test.ipa,
        principal: 'missing/ipa.nikita.local'
      .should.be.rejectedWith
        code: 4001
        message: 'missing/ipa.nikita.local@NIKITA.LOCAL: service not found'
