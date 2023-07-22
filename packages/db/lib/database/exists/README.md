
# `nikita.db.database.exists`

Check if a database exists.

The action returns an object whose value `exists` is the equivalent of `$status`. It is marked as `shy`, which means that it will not modify the status of its parent action.

## Sample

```js
const {exists} = nikita.db.database.exists({
  admin_username: 'root',
  admin_password: 'rootme',
  engine: 'postgresql',
  host: 'postgres',
  port: 5432,
  admin_db: 'root',
})
```
