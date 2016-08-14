
# `add(options, callback)`

Create a database for the destination database.

## Options

*   `admin_username`   
    The login of the database administrator. It should have credentials to create accounts.
*   `admin_password`   
    The password of the database administrator.
    provided.
*   `database` (Array or String)   
    The database name(s) to which the user should be added
*   `engine`      
    The engine type, can be MySQL or PostgreSQL. Default to MySQL
*   `host`   
    The hostname of the database
*   `port`   
    Port to the associated database
*   `user` Array or String   
    Contains  user(s) to add to the database.
    option if provided.
*   `log`   
    Function called with a log related messages.
*   `ssh` (object|ssh2)   
    Run the action on a remote server using SSH, an ssh2 instance or an
    configuration object used to initialize the SSH connection.
*   `stdout` (stream.Writable)   
    Writable EventEmitter in which the standard output of executed commands will
    be piped.
*   `stderr` (stream.Writable)   
    Writable EventEmitter in which the standard error output of executed command
    will be piped.

## Create Database example

```js
require('mecano').database.db.add({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db',
}, function(err, modified){
  console.log(err ? err.message : 'Principal created or modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Check main options
      return callback new Error 'Missing hostname' unless options.host?
      return callback new Error 'Missing admin name' unless options.admin_username?
      return callback new Error 'Missing admin password' unless options.admin_password?
      return callback new Error 'Missing database option ' unless options.database?
      options.database = [options.database] unless Array.isArray options.database
      options.user ?= []
      options.user = [options.user] unless Array.isArray options.user
      # Defines and check the engine type 
      options.engine = options.engine.toUpperCase() if options.engine?
      options.engine ?= 'POSTGRES'
      return callback new Error 'Unsupport engine type' unless options.engine in ['MYSQL','POSTGRES']
      options.log 'Missing engine type. Defaulting to PostgreSQL' unless options.engine?
      options.log message: "Database engine set to #{options.engine}", level: 'INFO', module: 'mecano/database/db/add'
      # Defines port
      options.port ?= 5432 
      options.log message: "Database port set to #{options.port}", level: 'DEBUG', module: 'mecano/database/db/add'
      adm_cmd = ''
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
      modified_user = false
      modified_db = false
      each options.database
        .parallel(false)
        .call ( db, i, next) =>
          return unless options.engine is 'POSTGRES'
          # Create database unless exist
          @call -> options.log message: "Check if database #{db} exists", level: 'DEBUG', module: 'mecano/database/db/add'
          @execute
            cmd: "#{adm_cmd} -tAc \"CREATE DATABASE #{db};\""
            unless_exec: "#{adm_cmd} -d #{db} -tAc '\\dt';"
          @call 
            if: -> @status -1
            handler: -> modified_db = true
          # Change password if needed
          # Even if the user exists, without database it can not connect.
          # That's why the check is executed in 2 steps.
          @call 
            handler: ->
              for user in options.user
                @call -> options.log message: "Check if user #{user} has PRIVILEGES on #{db} ", level: 'DEBUG', module: 'mecano/database/db/user'     
                @database.user.exists
                  name: user
                  admin_username: options.admin_username
                  admin_password: options.admin_password
                  port: options.port
                  host: options.host
                @call 
                  unless: -> @status -1
                  handler: -> options.log message: "User does exists #{user}: skipping", level: 'WARNING', module: 'mecano/database/db/add'
                @execute
                  if: -> @status -2
                  cmd: "#{adm_cmd} -d #{db} -tAc 'GRANT ALL PRIVILEGES ON DATABASE #{db} TO #{user}';"
                  unless_exec: "#{adm_cmd} -d #{db} -tAc \"SELECT datacl FROM  pg_database WHERE  datname = '#{db}'\" | grep '#{user}='"
                @call 
                  if: -> @status -2
                  handler: -> modified_user = true
          @then next  
        .then (err) -> 
          options.log message: "Modified Status for users", level: 'DEBUG', module: 'mecano/database/db/add' if modified_user
          options.log message: "Modified Status for databases", level: 'DEBUG', module: 'mecano/database/db/add' if modified_db
          callback err, (modified_user or modified_db)


## Dependencies

    misc = require '../../misc'
    each = require 'each'
