
# `nikita.db.user.remove`

Create a user for the destination database.

## Options

* `admin_username`   
  The login of the database administrator.   
* `admin_password`   
  The password of the database administrator.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL, default to MySQL.   
* `host`   
  The hostname of the database.   
* `username`   
  The new user name.   

## Source Code

    module.exports = ({metadata, options}) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      options.username ?= metadata.argument
      @system.execute
        cmd: db.cmd options, "DROP USER IF EXISTS #{options.username};"

## Dependencies

    db = require '@nikitajs/core/lib/misc/db'
