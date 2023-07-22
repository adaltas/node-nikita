# `nikita.db.database.wait`

Wait for the creation of a database.

## Create Database example

```js
const {$status} = await nikita.db.wait({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db'
})
console.info(`Did database existed initially: ${!$status}`)
```
