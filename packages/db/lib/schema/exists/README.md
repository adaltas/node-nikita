
# `nikita.db.schema.exists`

Create a database for the destination database.

## Create Schema example

```js
const {exists} = await nikita.db.schema.exists({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db'
})
console.info(`Schema exists: ${exists}`)
```
