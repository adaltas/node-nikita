
# `mecano.db.user(options, callback)`

Create a user for the destination database.

## Options

*   `admin_username`   
    The login of the database administrator. It should have credentials to create accounts.
*   `admin_password`   
    The password of the database administrator.
    provided.
*   `db` (Array or String)
    The database name(s) to which the user should be added
*   `engine`      
    The engine type, can be MySQL or PostgreSQL. Default to MySQL
*   `host`   
    The hostname of the database
*   `username`   
    The new user name.
*   `password`   
    The new user password.
*   `port`   
    Port to the associated database

## Source Code

    module.exports = (options) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Validate options
      throw Error 'Missing option: "host"' unless options.host
      throw Error 'Missing option: "admin_username"' unless options.admin_username
      throw Error 'Missing option: "admin_password"' unless options.admin_password
      throw Error 'Missing option: "username"' unless options.username
      throw Error 'Missing option: "password"' unless options.password
      throw Error 'Missing option: "engine"' unless options.engine
      # Defines and check the engine type 
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['postgres']
      # Default values
      options.port ?= 5432
      # Create user unless exist
      @execute
        cmd: db.cmd options, "CREATE USER #{options.username} WITH PASSWORD '#{options.password}';"
        unless_exec: db.cmd(options, "SELECT 1 FROM pg_roles WHERE rolname='#{options.username}'") + " | grep 1"
      , (err, status) ->
        return if err
        if status
        then options.log message: "User created: #{options.username}", level: 'WARN', module: 'mecano/db/user/add'
        else options.log message: "User already exists: #{options.username}", level: 'INFO', module: 'mecano/db/user/add'
      # Change password if needed
      # Even if the user exists, without database it can not connect.
      # That's why the check is executed in 2 steps.
      @execute
        cmd: db.cmd options, "ALTER USER #{options.username} WITH PASSWORD '#{options.password}';"
        if_exec: db.cmd(options, admin_username: null, admin_password: null, '\\dt') + " 2>&1 >/dev/null | grep -e '^psql:\\sFATAL.*password\\sauthentication\\sfailed\\sfor\\suser.*'"
      , (err, status) ->
        return if err
        if status
        then options.log message: "Password modified: user #{JSON.stringify options.username}", level: 'WARN', module: 'mecano/db/user/add'
        else options.log message: "Password not modified: user #{JSON.stringify options.username}", level: 'INFO', module: 'mecano/db/user/add'

## Dependencies

    db = require '../../misc/db'
    each = require 'each'
