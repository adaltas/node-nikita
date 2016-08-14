
# `mecano.database.user.add(options, callback)`

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
*   `name`   
    The new user name.
*   `password`   
    The new user password.
*   `port`   
    Port to the associated database
*   `users` Array   
    Array containing a list of user to create. It will take priority over name/password
    option if provided.

## Source Code

    module.exports = (options, callback) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Check main options
      return callback new Error 'Missing hostname' unless options.host?
      return callback new Error 'Missing admin name' unless options.admin_username?
      return callback new Error 'Missing admin password' unless options.admin_password?
      return callback new Error 'Missing new user name' unless options.name? or options.users?
      return callback new Error 'Missing new user password' unless options.password? or options.users?
      if options.db
        options.db = [options.db] unless Array.isArray options.db
      # Define and check the work array, definied if not exist, pushing in it the single user if empty
      options.users ?= []
      return callback new Error 'users  must be an array' unless Array.isArray options.users
      if options.name?
        options.users.push
          name: "#{options.name}"
          password: "#{options.password}"
      # Defines and check the engine type 
      options.engine = options.engine.toUpperCase() if options.engine?
      options.engine ?= 'POSTGRES'
      return callback new Error 'Unsupport engine type' unless options.engine in ['MYSQL','POSTGRES']
      options.log message: "Database engine set to #{options.engine}", level: 'INFO', module: 'mecano/database/user/add'
      # Defines port
      options.port ?= 5432      
      adm_cmd = ''
      create_cmd = ''
      switch options.engine
        when 'MYSQL'
          adm_cmd += 'mysql'
          adm_cmd += " -h #{options.host}"
          adm_cmd += " -u #{options.admin_username}"
          adm_cmd += " -p #{options.admin_password}"
          break;
        when 'POSTGRES'
          #psql does not have any option
          adm_cmd += "PGPASSWORD=#{options.admin_password} psql"
          adm_cmd += " -h #{options.host}"
          adm_cmd += " -U #{options.admin_username}"
          break;
        else
          break;
      
      # Manage modified status
      modified = false 
      @call ->
        each options.users 
          .parallel(false)
          .call (user, i, next) =>
            return unless options.engine is 'POSTGRES'
            user.databases ?= []
            # Create user  unless exist
            @execute
              cmd: "#{adm_cmd} -tAc \"CREATE USER #{user.name} WITH PASSWORD '#{user.password}';\""
              unless_exec: "#{adm_cmd} -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{user.name}'\" | grep 1"
            # Change password if needed
            # Even if the user exists, without database it can not connect.
            # That's why the check is executed in 2 steps.
            @execute
              cmd: "#{adm_cmd} -tAc \"ALTER USER #{user.name} WITH PASSWORD '#{user.password}';\""
              if_exec: "#{postgres.wrap options} -c \"\\dt\" 2>&1 >/dev/null | grep -e '^psql:\\sFATAL.*password\\sauthentication\\sfailed\\sfor\\suser.*'"
              # This message is an error and is written to stderr, so it is redirected to stdout before being grepped
              #unless_exec: "#{postgres.wrap options} -c '\\dt' | egrep  '^psql:\\sFATAL.*database.*\\sdoes\\snot\\sexist$'"
            @call 
              if: -> (@status -1) or (@status -1)
              handler: -> modified = true
            @call 
              if: -> @status -3
              handler: -> options.log message: "User created: #{user.name}", level: 'INFO', module: 'mecano/database/user/add'
            @call 
              unless: -> @status -4
              handler: -> options.log message: "User already exist (skipped): #{user.name}", level: 'INFO', module: 'mecano/database/user/add'
            @call 
              if: -> @status -3
              handler: -> options.log message: "Modified Password for user: #{user.name}", level: 'INFO', module: 'mecano/database/user/add'
            @then next
          .then (err) -> callback err, modified
      


## Dependencies

    misc = require '../../misc'
    postgres = require '../../misc/database'
    each = require 'each'
