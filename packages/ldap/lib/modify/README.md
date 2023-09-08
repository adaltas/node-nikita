
# `nikita.ldap.modify`

Insert, modify or remove entries inside an OpenLDAP server.   

## Example

```js
const {$status} = await nikita.ldap.modify({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,dc=company,dc=com',
  passwd: 'secret',
  operations: [{
    'dn': 'cn=my_group,ou=groups,dc=company,dc=com'
    'changetype': 'modify',
    'values': [{
      'replace': 'gidNumber',
      'gidNumber': 9602,
    }]
  }]
})
console.info(`Entry modified: ${$status}`)
```
