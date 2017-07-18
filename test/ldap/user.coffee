
nikita = require '../../src'
test = require '../test'

describe 'ldap.user', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_ldap_user

  it 'create a new user', ->
    @timeout 100000
    nikita
      binddn: config.ldap.binddn
      passwd: config.ldap.passwd
      uri: config.ldap.uri
    .ldap.user
      user:
        dn: "cn=nikita,#{config.ldap.suffix_dn}"
        userPassword: 'test'
        uid: 'nikita'
        objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
        shadowLastChange: '15140'
        shadowMin: '0'
        shadowMax: '99999'
        shadowWarning: '7'
        loginShell: '/bin/bash'
        uidNumber: '9610'
        gidNumber: '9610'
        homeDirectory: '/home/nikita'
    .then (err, modified) ->
      throw err if err
      modified.should.be.true()
    .ldap.delete
      dn: "cn=nikita,#{config.ldap.suffix_dn}"
    .promise()

  it 'detect no change', ->
    @timeout 100000
    user =
      dn: "cn=nikita,#{config.ldap.suffix_dn}"
      userPassword: 'test'
      uid: 'nikita'
      objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
      shadowLastChange: '15140'
      shadowMin: '0'
      shadowMax: '99999'
      shadowWarning: '7'
      loginShell: '/bin/bash'
      uidNumber: '9610'
      gidNumber: '9610'
      homeDirectory: '/home/nikita'
    nikita
      binddn: config.ldap.binddn
      passwd: config.ldap.passwd
      uri: config.ldap.uri
    .ldap.user
      user: user
    .then ->
      return # reset status
    .ldap.user
      user: user
    .then (err, modified) ->
      throw err if err
      modified.should.be.false()
    .ldap.delete
      dn: "cn=nikita,#{config.ldap.suffix_dn}"
    .promise()
