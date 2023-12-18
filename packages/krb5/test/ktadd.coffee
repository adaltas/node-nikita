
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'krb5.ktadd', ->
  return unless test.tags.krb5_ktadd

  they 'create a new keytab', ({ssh}) ->
    nikita
      $ssh: ssh
      krb5: admin: test.krb5
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @krb5.addprinc
        principal: "nikita@#{test.krb5.realm}"
        randkey: true
      {$status} = await @krb5.ktadd
        principal: "nikita@#{test.krb5.realm}"
        keytab: "#{tmpdir}/nikita.keytab"
      $status.should.be.true()
      {$status} = await @krb5.ktadd
        principal: "nikita@#{test.krb5.realm}"
        keytab: "#{tmpdir}/nikita.keytab"
      $status.should.be.false()

  they 'detect kvno', ({ssh}) ->
    nikita
      $ssh: ssh
      krb5: admin: test.krb5
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @krb5.addprinc
        principal: "nikita@#{test.krb5.realm}"
        randkey: true
      await @krb5.ktadd
        principal: "nikita@#{test.krb5.realm}"
        keytab: "#{tmpdir}/nikita_1.keytab"
      await @krb5.ktadd
        principal: "nikita@#{test.krb5.realm}"
        keytab: "#{tmpdir}/nikita_2.keytab"
      {$status} = await @krb5.ktadd
        principal: "nikita@#{test.krb5.realm}"
        keytab: "#{tmpdir}/nikita_1.keytab"
      $status.should.be.true()
      {$status} = await @krb5.ktadd
        principal: "nikita@#{test.krb5.realm}"
        keytab: "#{tmpdir}/nikita_1.keytab"
      $status.should.be.false()

  they 'change permission', ({ssh}) ->
    nikita
      $ssh: ssh
      krb5: admin: test.krb5
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @krb5.addprinc
        principal: "nikita@#{test.krb5.realm}"
        randkey: true
      await @krb5.ktadd
        principal: "nikita@#{test.krb5.realm}"
        keytab: "#{tmpdir}/nikita.keytab"
        mode: 0o0755
      {$status} = await @krb5.ktadd
        principal: "nikita@#{test.krb5.realm}"
        keytab: "#{tmpdir}/nikita.keytab"
        mode: 0o0707
      $status.should.be.true()
