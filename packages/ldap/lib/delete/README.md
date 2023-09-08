
# `nikita.ldap.delete`

Insert or modify an entry inside an OpenLDAP server.   

## Example

```js
const {$status} = await nikita.ldap.delete({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  dn: 'cn=group1,ou=groups,dc=company,dc=com'
})
console.info(`Entry deleted: ${$status}`)
```
