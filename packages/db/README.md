
# Nikita "db" package

The "db" package provides Nikita actions for various database operations. Currently supports PostgreSQL, MySQL and MariaDB.

## Usage

```js
import "@nikitajs/db/register";
import nikita from "@nikitajs/core";

const { exists } = nikita.db.database.exists({
  admin_username: "root",
  admin_password: "rootme",
  database: "test_database_exists_0_db",
  engine: "postgresql",
  host: "postgres",
  port: 5432,
});
console.info(exists);
```
