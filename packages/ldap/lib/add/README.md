
# `nikita.ldap.add`

Insert or modify an entry inside an OpenLDAP server.   

## Example

```js
const {$status} = await nikita.ldap.index({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  entry: {
    dn: 'cn=group1,ou=groups,dc=company,dc=com'
    cn: 'group1'
    objectClass: 'top'
    objectClass: 'posixGroup'
    gidNumber: 9601
  }
})
console.info(`Entry modified: ${$status}`)
```
