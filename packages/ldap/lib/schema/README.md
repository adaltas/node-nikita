
# `nikita.ldap.schema`

Register a new ldap schema.

## Example

```js
const {$status} = await nikita.ldap.schema({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'kerberos',
  schema: '/usr/share/doc/krb5-server-ldap-1.10.3/kerberos.schema'
})
console.info(`Schema created or modified: ${$status}`)
```
