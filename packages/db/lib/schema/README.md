
# `nikita.db.schema`

Create or modify a schema for the destination database.

A PostgreSQL database contains one or multiple schemas which in turns contains
table, data types, functions, and operators.

Note, PostgreSQL default to the default `root` database while Nikita enforce the
presence of the targeted database.

## Create Schema example

```js
const {$status} = await nikita.db.schema({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_database'
  schema: 'my_schema'
})
console.info(`Schema created or modified: ${$status}`)
```
