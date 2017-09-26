
# `nikita.db.schema.remove`

Create a user for the destination database.

## Options

* `admin_username`   
  The login of the database administrator. It should have credentials to 
  create accounts.   
* `admin_password`   
  The password of the database administrator.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL, default to MySQL.   
* `host`   
  The hostname of the database.   
* `schema`   
  New schema name.   

## Source Code

    module.exports = (options) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Options
      options.schema ?= options.argument
      throw Error 'Missing option: "engine"' unless options.engine
      throw Error 'Missing option: "schema"' unless options.schema
      throw Error 'Missing option: "admin_username"' unless options.admin_username
      throw Error 'Missing option: "admin_password"' unless options.admin_password
      # Deprecation
      if options.engine is 'postgresql'
        console.log 'Depracated Value: options "postgres" is deprecated in favor of "postgresql"'
        options.engine = 'postgresql'
      # Defines and check the engine type 
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['postgresql']
      @system.execute
        cmd: db.cmd options, "DROP SCHEMA IF EXISTS #{options.schema};"

## Dependencies

    db = require '../../misc/db'
