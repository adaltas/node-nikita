
# `nikita.ldap.index`

Create new [index](http://www.zytrax.com/books/ldap/apa/indeces.html) in an OpenLDAP server.   

## Example

Using the database DN:

```js
const {$status} = await nikita.ldap.index({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  dn: 'olcDatabase={2}bdb,cn=config',
  indexes: {
    krbPrincipalName: 'sub,eq'
  }
})
console.info(`Index created or modified: ${$status}`)
```

Using the database suffix:

```js
const {$status} = await nikita.ldap.index({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  suffix: 'dc=example,dc=org',
  indexes: {
    krbPrincipalName: 'sub,eq'
  }
})
console.info(`Index created or modified: ${$status}`)
```
