
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'krb5.execute', ->
  return unless test.tags.krb5

  describe 'schema', ->

    it 'admin and command must be provided', ->
      nikita
      .krb5.execute {}
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `krb5.execute`:'
          '#/required config must have required property \'admin\';'
          '#/required config must have required property \'command\'.'
        ].join ' '

  describe 'action', ->

    they 'global properties', ({ssh}) ->
      nikita
        $ssh: ssh
        krb5: admin: test.krb5
      , ->
        {stdout} = await @krb5.execute
          command: 'listprincs'
        stdout.should.containEql 'kadmin/admin'

    they 'option command', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {stdout} = await @krb5.execute
          admin: test.krb5
          command: 'listprincs'
        stdout.should.containEql 'kadmin/admin'

    they 'config grep with string', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status} = await @krb5.execute
          admin: test.krb5
          command: 'listprincs'
          grep: test.krb5.principal
        $status.should.be.true()
        {$status} = await @krb5.execute
          admin: test.krb5
          command: 'listprincs'
          grep: "missing string"
        $status.should.be.false()

    they 'config grep with regexp', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        {$status, stdout} = await @krb5.execute
          admin: test.krb5
          command: 'listprincs'
          grep: /^.*@.*$/
        $status.should.be.true()
        {$status, stdout} = await @krb5.execute
          admin: test.krb5
          command: 'listprincs'
          grep: /^.*missing.*$/
        $status.should.be.false()
        
