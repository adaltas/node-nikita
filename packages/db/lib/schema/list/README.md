
# `nikita.db.schema.list`

List the PostgreSQL schemas of a database.

## Create Schema example

```js
const {schemas} = await nikita.db.schema.list({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db'
})
schemas.map( ({name, owner}) => {
  console.info(`Schema is ${name} and owner is ${owner}`)
})
```
