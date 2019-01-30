
nikita = require '@nikitajs/core'
{tags, ssh, ldap} = require './test'
they = require('ssh2-they').configure(ssh)

return unless tags.ldap_acl

describe 'ldap.acl', ->
  
  client = olcAccess = null
  beforeEach (next) ->
    client = ldap.createClient url: ldap.url
    client.bind ldap.binddn, ldap.passwd, (err) ->
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

  they 'create a new permission', (ssh) ->
    nikita
      ssh: ssh
    .ldap.acl
      # ldap: client
      url: ldap.url
      binddn: ldap.binddn
      passwd: ldap.passwd
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
      ]
    , (err, {status}) ->
      status.should.be.true()
    .ldap.acl
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
      ]
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  they 'respect order in creation', (ssh) ->
    nikita
      ssh: ssh
    .ldap.acl
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="ou=test1,dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
      ]
    .ldap.acl
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="ou=test2,dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
      ]
    .ldap.acl
      ldap: client
      name: 'olcDatabase={2}bdb,cn=config'
      to: 'dn.base="ou=INSERTED,dc=test,dc=com"'
      place_before: 'dn.base="ou=test2,dc=test,dc=com"'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read'
      ]
    .call (_, callback) ->
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
        search.on 'end', callback
      .promise()
