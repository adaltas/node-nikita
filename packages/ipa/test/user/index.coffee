
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

userMatch = 
  sn: [ 'Lastname' ],
  loginshell: [ '/bin/sh' ],
  krbprincipalname: [ 'user_add@NIKITA.LOCAL' ],
  uidnumber: [ /\d+/ ],
  uid: [ 'user_add' ],
  mail: [ 'user@nikita.js.org' ],
  gidnumber: [ /\d+/ ],
  givenname: [ 'Firstname' ],
  homedirectory: [ '/home/user_add' ],
  krbcanonicalname: [ 'user_add@NIKITA.LOCAL' ],
  has_password: false,
  has_keytab: false,
  memberof_group: [ 'ipausers' ]

describe 'ipa.user', ->
  return unless test.tags.ipa

  describe 'schema', ->
  
    it 'schema root properties', ->
      nikita
      .ipa.user
        uid: [1,2,3]
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `ipa.user`:'
          '#/properties/uid/type config/uid must be string, type is "string";'
          '#/required config must have required property \'attributes\';'
          '#/required config must have required property \'connection\'.'
        ].join ' '

    it 'schema connection properties', ->
      nikita
      .ipa.user
        uid: 'username'
        attributes: {}
        connection: principal: [1,2,3]
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `ipa.user`:'
          '#/properties/connection/required config/connection must have required property \'password\';'
          '#/properties/principal/type config/connection/principal must be string, type is "string";'
          '#/required config/connection must have required property \'url\'.'
        ].join ' '

    it 'coercion of `mail` attribute', ->
      nikita.ipa.user
        uid: 'username'
        attributes:
          givenname: 'Firstname'
          sn: 'Lastname'
          mail: 'user@nikita.js.org'
        connection: test.ipa

  describe 'action', ->

    they 'create a user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user.del
          uid: 'user_add'
          connection: test.ipa
        {$status, result} = await @ipa.user
          uid: 'user_add'
          attributes:
            givenname: 'Firstname'
            sn: 'Lastname'
            mail: [ 'user@nikita.js.org' ]
          connection: test.ipa
        $status.should.be.true()
        result.should.match userMatch

    they 'modify a user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user.del connection: test.ipa,
          uid: 'user_add'
        await @ipa.user
          uid: 'user_add'
          attributes:
            givenname: 'Firstname 1'
            sn: 'Lastname'
            mail: [ 'user@nikita.js.org' ]
          connection: test.ipa
        {$status, result} = await @ipa.user
          uid: 'user_add'
          attributes:
            givenname: 'Firstname 2'
            sn: 'Lastname'
            mail: [ 'user@nikita.js.org' ]
          connection: test.ipa
        $status.should.be.true()
        result.should.match {...userMatch, givenname: ['Firstname 2']}

    they 'dont modify a user', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user.del
          uid: 'user_add'
          connection: test.ipa
        {$status} = await @ipa.user
          uid: 'user_add'
          attributes:
            givenname: 'Firstname'
            sn: 'Lastname'
            mail: [ 'user@nikita.js.org' ]
          connection: test.ipa
        {$status, result} = await @ipa.user
          uid: 'user_add'
          attributes:
            givenname: 'Firstname'
            sn: 'Lastname'
            mail: [ 'user@nikita.js.org' ]
          connection: test.ipa
        $status.should.be.false()
        result.should.match userMatch

    they 'modify password', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user.del
          connection: test.ipa
          uid: 'user_add'
        await @ipa.user
          attributes:
            givenname: 'Firstname 1'
            sn: 'Lastname'
            mail: [ 'user@nikita.js.org' ]
            userpassword: 'toto'
          connection: test.ipa
          uid: 'user_add'
        {$status} = await @ipa.user
          uid: 'user_add'
          attributes:
            userpassword: 'toto'
          connection: test.ipa
        $status.should.be.false()
        
    they 'modify password', ({ssh}) ->
      nikita
        $ssh: ssh
      , ->
        await @ipa.user.del
          connection: test.ipa
          uid: 'user_add'
        await @ipa.user
          attributes:
            givenname: 'Firstname 1'
            sn: 'Lastname'
            mail: [ 'user@nikita.js.org' ]
            userpassword: 'toto'
          connection: test.ipa
          uid: 'user_add'
        {$status} = await @ipa.user
          attributes:
            userpassword: 'toto'
          connection: test.ipa
          force_userpassword: true
          uid: 'user_add'
        $status.should.be.true()
