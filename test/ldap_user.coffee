
mecano = require "../src"
test = require './test'
ldap = require 'ldapjs'

describe 'ldap_user', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_ldap_user

  it 'create a new user', (next) ->
    @timeout 100000
    mecano
      binddn: config.ldap.binddn
      passwd: config.ldap.passwd
      uri: config.ldap.uri
    .ldap_user
      user:
        dn: "cn=mecano,#{config.ldap.suffix_dn}"
        userPassword: 'test'
        uid: 'mecano'
        objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
        shadowLastChange: '15140'
        shadowMin: '0'
        shadowMax: '99999'
        shadowWarning: '7'
        loginShell: '/bin/bash'
        uidNumber: '9610'
        gidNumber: '9610'
        homeDirectory: '/home/mecano'
    .then (err, modified) ->
      throw err if err
      modified.should.be.true()
    .ldap_delete
      dn: "cn=mecano,#{config.ldap.suffix_dn}"
    .then next

  it 'detect no change', (next) ->
    @timeout 100000
    user = 
      dn: "cn=mecano,#{config.ldap.suffix_dn}"
      userPassword: 'test'
      uid: 'mecano'
      objectClass: [ 'top', 'account', 'posixAccount', 'shadowAccount' ]
      shadowLastChange: '15140'
      shadowMin: '0'
      shadowMax: '99999'
      shadowWarning: '7'
      loginShell: '/bin/bash'
      uidNumber: '9610'
      gidNumber: '9610'
      homeDirectory: '/home/mecano'
    mecano
      binddn: config.ldap.binddn
      passwd: config.ldap.passwd
      uri: config.ldap.uri
    .ldap_user
      user: user
    .then ->
      return # reset status
    .ldap_user
      user: user
    .then (err, modified) ->
      throw err if err
      modified.should.be.false()
    .ldap_delete
      dn: "cn=mecano,#{config.ldap.suffix_dn}"
    .then next


