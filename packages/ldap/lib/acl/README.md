
# `nikita.ldap.acl`

Create new [ACLs](http://www.openldap.org/doc/admin24/access-control.html) for the OpenLDAP server.

## Example

```js
const {$status} = await nikita.ldap.acl({
  dn: '',
  acls: [{
    place_before: 'dn.subtree="dc=domain,dc=com"',
    to: 'dn.subtree="ou=users,dc=domain,dc=com"',
    by: [
      'dn.exact="ou=users,dc=domain,dc=com" write',
      'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read',
      '* none'
    ]
  },{
    to: 'dn.subtree="dc=domain,dc=com"',
    by: [
      'dn.exact="ou=kerberos,dc=domain,dc=com" write'
    ]
  }]
})
console.info(`ACL modified: ${$status}`)
```
