
# `nikita.ldap.search`

Opens a connection to an LDAP server, binds, and performs a search using
specified parameters. 

## Example

```js
const {stdout} = await nikita.ldap.search({
  base: 'dc=example,dc=org'
})
console.info(stdout)
// dn: dc=example,dc=org
```
