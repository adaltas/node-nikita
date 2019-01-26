
# `nikita.db.database.remove`

Create a user for the destination database.

## Options

* `admin_username`   
  The login of the database administrator.   
* `admin_password`   
  The password of the database administrator.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL. Default to MySQL   
* `host`   
  The hostname of the database   
* `database`   
  The database to be removed.   

## Source Code

    module.exports = ({options}) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      options.database ?= options.argument
      throw Error 'Missing option: "admin_username"' unless options.admin_username
      throw Error 'Missing option: "admin_password"' unless options.admin_password
      # Avoid Postgres error "ERROR:  cannot drop the currently open database"
      database = options.database
      delete options.database
      @system.execute
        cmd: db.cmd options, "DROP DATABASE IF EXISTS #{database};"
        code_skipped: 2

## Dependencies

    db = require '@nikita/core/lib/misc/db'
