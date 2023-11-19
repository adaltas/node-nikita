
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'krb5.delprinc', ->
  return unless test.tags.krb5_delprinc

  they 'a principal which exists', ({ssh}) ->
    nikita
      $ssh: ssh
      krb5: admin: test.krb5
    , ->
      await @krb5.addprinc
        principal: "nikita@#{test.krb5.realm}"
        randkey: true
      {$status} = await @krb5.delprinc
        principal: "nikita@#{test.krb5.realm}"
      $status.should.be.true()

  they 'a principal which does not exist', ({ssh}) ->
    nikita
      $ssh: ssh
      krb5: admin: test.krb5
    , ->
      await @krb5.delprinc
        principal: "nikita@#{test.krb5.realm}"
      {$status} = await @krb5.delprinc
        principal: "nikita@#{test.krb5.realm}"
      $status.should.be.false()
