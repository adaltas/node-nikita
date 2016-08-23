
# `mecano.db.user.exists(options, callback)`

Chek is user exists in the database.

## Options

*   `admin_username`   
    The login of the database administrator. It should have credentials to 
    create accounts.   
*   `admin_password`   
    The password of the database administrator.
*   `database` (String)
    The database name to which the user should be added.   
*   `engine`      
    The engine type, can be MySQL or PostgreSQL, default to MySQL.   
*   `host`   
    The hostname of the database.   
*   `name`   
    The new user name.   
*   `password`   
    The new user password.   
*   `port`   
    Port to the associated database.   
*   `user` String   
    User name.   

## Source Code

    module.exports = shy: true, handler: (options) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Check main options
      throw Error 'Missing hostname' unless options.host?
      throw Error 'Missing admin name' unless options.admin_username?
      throw Error 'Missing admin password' unless options.admin_password?
      throw Error 'Missing name' unless options.name?
      # Defines and check the engine type
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['postgres']
      # Defines port
      options.port ?= 5432      
      cmd = switch options.engine
        when 'mysql'
          db.cmd(options, database: 'mysql', "select User from user where User = '#{options.name}'") + " | grep '#{options.name}'"
        when 'postgres'
          db.cmd(options, "SELECT 1 FROM pg_roles WHERE rolname='#{options.name}'") + " | grep 1"
      @execute
        cmd: cmd
        code_skipped: 1

## Dependencies

    db = require '../../misc/db'
