
import ldap from '@nikitajs/ldap/utils/ldap'
import test from '../test.coffee'

describe 'utils.ldap acl', ->
  return unless test.tags.api

  it 'parse', ->
    ldap.acl
    .parse [ '{0}to attrs=userPassword,userPKCS12 by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by dn.exact="cn=nssproxy,ou=users,dc=adaltas,dc=com" read by self write by anonymous auth by * none' ]
    .should.eql [
      index: 0
      to: 'attrs=userPassword,userPKCS12'
      by: [ 'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
        'dn.exact="cn=nssproxy,ou=users,dc=adaltas,dc=com" read'
        'self write'
        'anonymous auth'
        '* none'
      ]
    ]

  it 'stringify', ->
    ldap.acl
    .stringify [
      index: 0
      to: 'attrs=userPassword,userPKCS12'
      by: [ 'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
        'dn.exact="cn=nssproxy,ou=users,dc=adaltas,dc=com" read'
        'self write'
        'anonymous auth'
        '* none'
      ]
    ]
    .should.eql [ '{0}to attrs=userPassword,userPKCS12 by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage by dn.exact="cn=nssproxy,ou=users,dc=adaltas,dc=com" read by self write by anonymous auth by * none' ]
