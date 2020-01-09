
# `nikita.db.user`

Create a user for the destination database.

## Options

* `admin_username`   
  The login of the database administrator. It should have credentials to 
  create accounts.   
* `admin_password`   
  The password of the database administrator.   
* `db` (Array or String)   
  The database name(s) to which the user should be added.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL, default to MySQL.   
* `host`   
  The hostname of the database.   
* `username`   
  The new user name.   
* `password`   
  The new user password.   
* `port`   
  Port to the associated database.   

## Schema

    schema = null
      # type: 'object'
      # properties:
      #   $ref: '/nikita/db/query'
      #   'username': type: 'string'
      #   'password': type: 'string'
      # required: [
      #   'username', 'password' ]

## Hander

    handler = ({options}) ->
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
      # Deprecation
      if options.engine is 'postgres'
        console.log 'Deprecated Value: options "postgres" is deprecated in favor of "postgresql"'
        options.engine = 'postgresql'
      # Defines and check the engine type
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['mariadb', 'mysql', 'postgresql']
      # Default values
      options.port ?= 5432
      # Commands
      switch options.engine
        when 'mariadb', 'mysql'
          cmd_user_exists = cmd(options, "SELECT User FROM mysql.user WHERE User='#{options.username}'") + " | grep #{options.username}"
          cmd_user_create = cmd options, "CREATE USER #{options.username} IDENTIFIED BY '#{options.password}';"
          cmd_password_is_invalid = cmd(options, admin_username: options.username, admin_password: options.password, '\\dt') + " 2>&1 >/dev/null | grep -e '^ERROR 1045.*'"
          cmd_password_change = cmd options, "SET PASSWORD FOR #{options.username} = PASSWORD ('#{options.password}');"
        when 'postgresql'
          cmd_user_exists = cmd(options, "SELECT 1 FROM pg_roles WHERE rolname='#{options.username}'") + " | grep 1"
          cmd_user_create = cmd options, "CREATE USER #{options.username} WITH PASSWORD '#{options.password}';"
          cmd_password_is_invalid = cmd(options, admin_username: options.username, admin_password: options.password, '\\dt') + " 2>&1 >/dev/null | grep -e '^psql:\\sFATAL.*password\\sauthentication\\sfailed\\sfor\\suser.*'"
          cmd_password_change = cmd options, "ALTER USER #{options.username} WITH PASSWORD '#{options.password}';"
      @system.execute
        cmd: """
        signal=3
        if #{cmd_user_exists}; then
          echo '[INFO] User already exists'
        else
          #{cmd_user_create}
          echo '[WARN] User created'
          signal=0
        fi
        if [ $signal -eq 3 ]; then
          if ! #{cmd_password_is_invalid}; then
            echo '[INFO] Password not modified'
          else
            #{cmd_password_change}
            echo '[WARN] Password modified'
            signal=0
          fi
        fi
        exit $signal
        """
        code_skipped: 3
        trap: true
## Source Code

    module.exports =
      handler: handler
      schema: schema

## Dependencies

    {cmd} = require '../query'
