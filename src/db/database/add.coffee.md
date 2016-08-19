
# `mecano.db.database.add(options, callback)`

Create a database for the destination database.

## Options

*   `admin_username`   
    The login of the database administrator. It should have credentials to create accounts.   
*   `admin_password`   
    The password of the database administrator.   
*   `database` (Array or String)   
    The database name(s) to which the user should be added.   
*   `engine`      
    The engine type, can be MySQL or PostgreSQL, required.   
*   `host`   
    The hostname of the database.   
*   `port`   
    Port to the associated database.   
*   `user` Array or String   
    Contains  user(s) to add to the database, optional.   
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

## Run the tests

```
cd docker/centos6
# then
docker-compose run --rm nodejs test/db/database.coffee
# or
docker-compose run --rm nodejs
npm test test/db/database.coffee
```

## Source Code

    module.exports = (options) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Validate options
      throw Error 'Missing option: "host"' unless options.host
      throw Error 'Missing option: "admin_username"' unless options.admin_username
      throw Error 'Missing option: "admin_password"' unless options.admin_password
      throw Error 'Missing option: "database"' unless options.database
      throw Error 'Missing option: "engine"' unless options.engine
      options.user ?= []
      options.user = [options.user] unless Array.isArray options.user
      # Defines and check the engine type 
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['postgres']
      options.log message: "Database engine set to #{options.engine}", level: 'INFO', module: 'mecano/db/database/add'
      # Default values
      options.port ?= 5432 
      # Create database unless exist
      options.log message: "Check if database #{options.database} exists", level: 'DEBUG', module: 'mecano/db/database/add'
      @execute
        cmd: db.cmd options, database: null, "CREATE DATABASE #{options.database};"
        unless_exec: db.cmd options, database: options.database, "\\dt"
      , (err, status) ->
        options.log message: "Database created: #{JSON.stringify options.database}", level: 'WARN', module: 'mecano/db/database/add' if status
      # Change password if needed
      # Even if the user exists, without database it can not connect.
      # That's why the check is executed in 2 steps.
      for user in options.user
        options.log message: "Check if user #{user} has PRIVILEGES on #{options.database} ", level: 'DEBUG', module: 'mecano/db/database/user'     
        @db.user.exists
          name: user
          admin_username: options.admin_username
          admin_password: options.admin_password
          port: options.port
          host: options.host
        , (err, exists) ->
          options.log message: "User does exists #{user}: skipping", level: 'WARNING', module: 'mecano/db/database/add' unless exists
        @execute
          if: -> @status -1
          cmd: db.cmd options, database: options.database, "GRANT ALL PRIVILEGES ON DATABASE #{options.database} TO #{user}"
          unless_exec: db.cmd(options, database: options.database, "SELECT datacl FROM  pg_database WHERE  datname = '#{options.database}'") + " | grep '#{user}='"
        , (err, status) ->
          options.log message: "Privileges granted: to #{JSON.stringify user} on #{JSON.stringify options.database}", level: 'WARN', module: 'mecano/db/database/add' if status

## Dependencies

    db = require '../../misc/db'
    each = require 'each'
