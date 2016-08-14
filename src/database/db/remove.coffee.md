
# `mecano.database.user.remove(options, callback)`

Create a user for the destination database.

## Options

*   `admin_username`   
    The login of the database administrator. It should have credentials to create accounts.
*   `admin_password`   
    The password of the database administrator.
    provided.
*   `engine`      
    The engine type, can be MySQL or PostgreSQL. Default to MySQL
*   `host`   
    The hostname of the database
*   `database`   
    The database to be removed.

## Source Code

    module.exports = (options) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      options.database ?= options.argument
      @execute
        cmd: db.cmd options, "DROP DATABASE IF EXISTS #{options.database};"
        code_skipped: 1
        always: true

## Dependencies

    db = require '../../misc/db'
