
# `nikita.ldap.tools.databases`

List the databases of the OpenLDAP server. It returns the `olcDatabase` value.

## Example

```js
const {databases} = await nikita.ldap.tools.databases({
  uri: 'ldap://localhost',
  binddn: 'cn=admin,cn=config',
  passwd: 'config'
})
// Value is similar to `[ '{-1}frontend', '{0}config', '{1}mdb' ]`
databases.map( database => {
  console.info(`Database: ${database}`)
})
```
