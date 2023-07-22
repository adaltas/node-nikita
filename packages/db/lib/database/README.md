# `nikita.db.database`

Create a database inside the destination datababse server.

## Create database example

```js
const {$status} = await nikita.database.db({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db',
})
console.info(`Database created or modified: ${$status}`)
```
