
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

## Schema

    schema =
      $ref: 'module://@nikitajs/ldap/src/search#/properties'

## Handler

    handler = ({config}) ->
      {stdout} = await @ldap.search config,
        base: 'cn=config'
        filter: '(objectClass=olcDatabaseConfig)'
        attributes: ['olcDatabase']
      databases = utils.string
      .lines stdout
      .filter (line) -> /^olcDatabase: /.test line
      .map (line) -> line.split(' ')[1]
      databases: databases

## Exports

    module.exports =
      handler: handler
      metadata:
        global: 'ldap'
      schema: schema

## Dependencies

    utils = require '../utils'
