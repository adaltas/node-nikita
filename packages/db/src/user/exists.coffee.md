
# `nikita.db.user.exists`

Check if a user exists in the database.

## Options

* `admin_username`   
  The login of the database administrator. It should have credentials to 
  create accounts.   
* `admin_password`   
  The password of the database administrator.   
* `database` (String)   
  The database name to which the user should be added.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL, default to MySQL.   
* `host`   
  The hostname of the database.   
* `username`   
  The new user name.    
* `port`   
  Port to the associated database.   

## Schema

    schema:
      type: 'object'
      properties:
        $ref: '/nikita/db/query'
        'username': type: 'string'
        'password': type: 'string'
        # 'connection':
        #   $ref: '/nikita/db/query'
      required: [
        'password', 'username' ]

## Source Code

    module.exports = shy: true, handler: ({options}, callback) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Check main options
      throw Error 'Missing option: "host"' unless options.host
      throw Error 'Missing option: "admin_username"' unless options.admin_username
      throw Error 'Missing option: "admin_password"' unless options.admin_password
      throw Error 'Missing option: "username"' unless options.username
      throw Error 'Missing option: "engine"' unless options.engine
      # Deprecation
      if options.engine is 'postgres'
        console.log 'Deprecated Value: options "postgres" is deprecated in favor of "postgresql"'
        options.engine = 'postgresql'
      # Defines and check the engine type
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['mariadb', 'mysql', 'postgresql']
      # Defines port
      options.port ?= 5432
      @db.query connection_options(options),
        database: undefined
        cmd: switch options.engine
          when 'mariadb', 'mysql'
            "SELECT User FROM mysql.user WHERE User = '#{options.username}'"
          when 'postgresql'
            "SELECT '#{options.username}' FROM pg_roles WHERE rolname='#{options.username}'"
        trim: true
      , (err, {stdout}) ->
        callback err, stdout is options.username

## Dependencies

    {connection_options} = require '../query'
