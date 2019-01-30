
# `nikita.db.database.exists`

Check if a database exists.

## Options

* `admin_username`   
  The login of the database administrator.   
* `admin_password`   
  The password of the database administrator.   
* `database` (String)   
  The database name to check for existance.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL, default to MySQL.   
* `host`   
  The hostname of the database.   
* `port`   
  Port to the associated database.   
* `username`   
  The username of a user with privileges on the database, used unless admin_username is provided.   
* `password`   
  The password of a user with privileges on the database, used unless admin_password is provided.   

## Source Code

    module.exports = shy: true, handler: ({options}) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      options.database ?= options.argument
      # Check main options
      throw Error 'Missing option: "host"' unless options.host
      throw Error 'Missing option: "username" or "admin_username"' unless options.admin_username or options.username
      throw Error 'Missing option: "admin_password"' if options.admin_username and not options.admin_password
      throw Error 'Missing option: "password"' if options.username and not options.password
      # Deprecation
      if options.engine is 'postgres'
        console.log 'Deprecated Value: options "postgres" is deprecated in favor of "postgresql"'
        options.engine = 'postgresql'
      # Defines and check the engine type
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['mariadb', 'mysql', 'postgresql']
      # Defines port
      options.port ?= 5432
      cmd = switch options.engine
        when 'mariadb', 'mysql'
          db.cmd(options, database: 'mysql', "SHOW DATABASES") + " | grep -w '#{options.database}'"
        when 'postgresql'
          # Not sure why we're not using \l
          db.cmd(options, "SELECT datname FROM pg_database WHERE datname = '#{options.database}'") + " | grep -w '#{options.database}'"
      @system.execute
        cmd: cmd
        code_skipped: 1

## Dependencies

    db = require '@nikitajs/core/lib/misc/db'
