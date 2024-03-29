
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'krb5.addprinc', ->
  return unless test.tags.krb5_addprinc

  describe 'schema', ->
    
    it 'admin and principal must be provided', ->
      nikita
      .krb5.addprinc
        randkey: true
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `krb5.addprinc`:'
          '#/required config must have required property \'admin\';'
          '#/required config must have required property \'principal\'.'
        ].join ' '

    it 'one of password or randkey must be provided', ->
      nikita
      .krb5.addprinc
        admin: test.krb5
        principal: "nikita@#{test.krb5.realm}"
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `krb5.addprinc`:'
          '#/oneOf config must match exactly one schema in oneOf, passingSchemas is null;'
          '#/oneOf/0/required config must have required property \'password\';'
          '#/oneOf/1/required config must have required property \'randkey\'.'
        ].join ' '

  describe 'action', ->

    they 'create a new principal with a randkey', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: test.krb5
      , ->
        await @krb5.delprinc
          principal: "nikita@#{test.krb5.realm}"
        {$status} = await @krb5.addprinc
          principal: "nikita@#{test.krb5.realm}"
          randkey: true
        $status.should.be.true()
        {$status} = await @krb5.addprinc
          principal: "nikita@#{test.krb5.realm}"
          randkey: true
        $status.should.be.false()

    they 'create a new principal with a password', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: test.krb5
      , ->
        await @krb5.delprinc
          principal: "nikita@#{test.krb5.realm}"
        {$status} = await @krb5.addprinc
          principal: "nikita@#{test.krb5.realm}"
          password: 'secret_1'
        # Change password
        $status.should.be.true()
        {$status} = await @krb5.addprinc
          principal: "nikita@#{test.krb5.realm}"
          password: 'secret_2'
          password_sync: true
        $status.should.be.true()
        # Check status
        {$status} = await @krb5.addprinc
          principal: "nikita@#{test.krb5.realm}"
          password: 'secret_2'
          password_sync: true
        $status.should.be.false()
        # Check token
        {$status} = await @execute
          command: "echo secret_2 | kinit nikita@#{test.krb5.realm}"
        $status.should.be.true()

    they 'dont overwrite password', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: test.krb5
      , ->
        await @krb5.delprinc
          principal: "nikita@#{test.krb5.realm}"
        {$status} = await @krb5.addprinc
          principal: "nikita@#{test.krb5.realm}"
          password: 'password1'
        $status.should.be.true()
        {$status} = await @krb5.addprinc
          principal: "nikita@#{test.krb5.realm}"
          password: 'password2'
          password_sync: false # Default
        $status.should.be.false()
        await @execute
          command: "echo password1 | kinit nikita@#{test.krb5.realm}"

    they 'with keybab', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: test.krb5
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.remove
          target: "#{tmpdir}/user1.service.keytab"
        await @krb5.delprinc
          principal: "user1/krb5@#{test.krb5.realm}"
        {$status} = await @krb5.addprinc
          principal: "user1/krb5@#{test.krb5.realm}"
          randkey: true
          keytab: "#{tmpdir}/user1.service.keytab"
        $status.should.be.true()
        {$status} = await @execute
          command: "kinit -kt #{tmpdir}/user1.service.keytab user1/krb5@#{test.krb5.realm}"
        $status.should.be.true()
