
# `nikita.db.database(options, callback)`

Create a database for the destination database.

## Options

* `admin_username`   
  The login of the database administrator.   
* `admin_password`   
  The password of the database administrator.   
* `database` (Array or String)   
  The database name(s) to which the user should be added.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL, required.   
* `host`   
  The hostname of the database.   
* `port`   
  Port to the associated database.   
* `user` (Array or String)   
  Contains  user(s) to add to the database, optional.   

This user will be granted superuser permissions (see above) for the database specified

## Create Database example

```js
require('nikita').database.db({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db',
}, function(err, status){
  console.log(err ? err.message : 'Database created or modified: ' + status);
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
      options.database ?= options.argument
      # Validate options
      throw Error 'Missing option: "host"' unless options.host
      throw Error 'Missing option: "admin_username"' unless options.admin_username
      throw Error 'Missing option: "admin_password"' unless options.admin_password
      throw Error 'Missing option: "database"' unless options.database
      throw Error 'Missing option: "engine"' unless options.engine
      options.user ?= []
      options.user = [options.user] if typeof options.user is 'string'
      # Deprecation
      if options.engine is 'postgresql'
        console.log 'Depracated Value: options "postgres" is deprecated in favor of "postgresql"'
        options.engine = 'postgresql'
      # Defines and check the engine type
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['mariadb', 'mysql', 'postgresql']
      options.log message: "Database engine set to #{options.engine}", level: 'INFO', module: 'nikita/db/database'
      # Default values
      options.port ?= 5432
      # Create database unless exist
      options.log message: "Check if database #{options.database} exists", level: 'DEBUG', module: 'nikita/db/database'
      switch options.engine
        when 'mariadb', 'mysql'
          cmd_database_create = db.cmd options, database: null, "CREATE DATABASE #{options.database} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
          cmd_database_exists = db.cmd options, database: options.database, "USE #{options.database};"
        when 'postgresql'
          cmd_database_create = db.cmd options, database: null, "CREATE DATABASE #{options.database};"
          cmd_database_exists = db.cmd options, database: options.database, "\\dt"
      @system.execute
        cmd: cmd_database_create
        unless_exec: cmd_database_exists
      , (err, status) ->
        options.log message: "Database created: #{JSON.stringify options.database}", level: 'WARN', module: 'nikita/db/database' if status
      for user in options.user then do =>
        @call -> options.log message: "Check if user #{user} has PRIVILEGES on #{options.database} ", level: 'DEBUG', module: 'nikita/db/database'     
        @db.user.exists
          engine: options.engine
          username: user
          admin_username: options.admin_username
          admin_password: options.admin_password
          port: options.port
          host: options.host
        , (err, exists) ->
          throw Error "DB user does not exists: #{user}" if not err and not exists
        switch options.engine
          when 'mariadb', 'mysql'
            # cmd_has_privileges = db.cmd options, admin_username: null, username: user.username, password: user.password, database: options.database, "SHOW TABLES FROM pg_database"
            cmd_has_privileges = db.cmd(options, database: 'mysql', "SELECT user FROM db WHERE db='#{options.database}';") + " | grep '#{user}'"
            cmd_grant_privileges = db.cmd options, database: null, "GRANT ALL PRIVILEGES ON #{options.database}.* TO '#{user}' WITH GRANT OPTION;" # FLUSH PRIVILEGES;
          when 'postgresql'
            cmd_has_privileges = db.cmd(options, database: options.database, "\\l") + " | egrep '^#{user}='"
            cmd_grant_privileges = db.cmd options, database: null, "GRANT ALL PRIVILEGES ON DATABASE #{options.database} TO #{user}"
        @system.execute
          cmd: """
          if #{cmd_has_privileges}; then
            echo '[INFO] User already with privileges'
            exit 3
          fi
          echo '[WARN] User privileges granted'
          #{cmd_grant_privileges}
          """
          code_skipped: 3
        , (err, status, stdout, stderr) ->
          options.log message: "Privileges granted: to #{JSON.stringify user} on #{JSON.stringify options.database}", level: 'WARN', module: 'nikita/db/database' if status

## Dependencies

    db = require '../../misc/db'
