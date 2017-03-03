
nikita = require '../../src'
test = require '../test'

describe 'ldap.acl', ->

  scratch = test.scratch @
  config = test.config()
  return if config.disable_ldap_acl
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
    nikita
    .ldap.acl
      # ldap: client
      url: config.ldap.url
      binddn: config.ldap.binddn
      passwd: config.ldap.passwd
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
      ]
    , (err, modified) ->
      modified.should.be.true()
    .ldap.acl
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
      ]
    , (err, modified) ->
      modified.should.be.false()
    .then next

  it 'respect order in creation', (next) ->
    nikita.ldap.acl [
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="ou=test1,dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
      ]
    ,
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="ou=test2,dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
      ]
    ], (err, modified) ->
      return next err if err
      nikita.ldap.acl
        ldap: client
        name: 'olcDatabase={2}bdb,cn=config'
        to: 'dn.base="ou=INSERTED,dc=test,dc=com"'
        place_before: 'dn.base="ou=test2,dc=test,dc=com"'
        by: [
          'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
        ]
      , (err, modified) ->
        return next err if err
        client.search 'olcDatabase={2}bdb,cn=config',
          scope: 'base'
          attributes:['olcAccess']
        , (err, search) ->
          search.on 'searchEntry', (entry) ->
            accesses = entry.object.olcAccess
            for access, i in accesses
              if /\{\d+\}(.*?) by/.exec(access)[1] is 'to dn.base="ou=test1,dc=test,dc=com"'
                /\{\d+\}(.*?) by/.exec(accesses[i+1])[1].should.eql 'to dn.base="ou=INSERTED,dc=test,dc=com"'
                /\{\d+\}(.*?) by/.exec(accesses[i+2])[1].should.eql 'to dn.base="ou=test2,dc=test,dc=com"'
                break
          search.on 'end', ->
            next()
