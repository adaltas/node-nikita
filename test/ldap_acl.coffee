
should = require 'should'
mecano = if process.env.MECANO_COV then require '../lib-cov/mecano' else require '../lib/mecano'
test = require './test'
ldap = require 'ldapjs'

describe 'ldap_acl', ->

  scratch = test.scratch @
  config = test.config()
  return unless config.ldap
  client = olcAccess = null
  beforeEach (next) ->
    client = ldap.createClient url: config.ldap.url
    client.bind config.ldap.binddn, config.ldap.passwd, (err) ->
      return next err if err
      client.search 'olcDatabase={2}bdb,cn=config',
        scope: 'base'
        attributes:['olcAccess']
      , (err, search) ->
        search.on 'searchEntry', (entry) ->
          olcAccess = entry.object.olcAccess
        search.on 'end', ->
          next()
  afterEach (next) ->
    change = new ldap.Change 
      operation: 'replace'
      modification: olcAccess: olcAccess
    client.modify 'olcDatabase={2}bdb,cn=config', change, (err) ->
      client.unbind (err) ->
        next err

  it 'create a new permission', (next) ->
    mecano.ldap_acl
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
      ]
    , (err, modified) ->
      return next err if err
      modified.should.eql 1
      mecano.ldap_acl
        ldap: client
        name: 'olcDatabase={2}bdb,cn=config'
        to: 'dn.base="dc=test,dc=com"'
        by: [
          'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
        ]
      , (err, modified) ->
        return next err if err
        modified.should.eql 0
        next()

