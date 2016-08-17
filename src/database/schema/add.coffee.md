
# `add(options, callback)`

Create a database for the destination database.

## Options

*   `admin_username`   
    The login of the database administrator. It should have credentials to create accounts.
*   `admin_password`   
    The password of the database administrator.
    provided.
*   `database` (String)   
    The database name where the schema is created.
*   `engine`      
    The engine type, can be MySQL or PostgreSQL. Default to MySQL
*   `host`   
    The hostname of the database
*   `port`   
    Port to the associated database
*   `schema`   
    New schema name.
*   `owner` Array or String   
    The Schema owner. Alter Schema if schema already exists.
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

## Create Schema example

```js
require('mecano').database.schema.add({
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
      # Defines and check the engine type 
      options.engine = options.engine.toUpperCase() if options.engine?
      options.engine ?= 'POSTGRES'
      return callback new Error 'Unsupport engine type' unless options.engine in ['POSTGRES'] #will be ['MYSQL','POSTGRESQL'] 
      options.log 'Missing engine type. Defaulting to PostgreSQL' unless options.engine?
      options.log message: "Database engine set to #{options.engine}", level: 'INFO', module: 'mecano/database/db/user'
      # Defines port
      options.port ?= 5432 
      options.log message: "Database port set to #{options.port}", level: 'DEBUG', module: 'mecano/database/db/user'     
      adm_cmd = ''
      error = null
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
      modified = false
      @call 
        if:  options.engine is 'POSTGRES'
        handler: ->  # Create Schema unless exist
          @call -> options.log message: "Check if schema #{options.schema} exists", level: 'DEBUG', module: 'mecano/database/schema/add'     
          @call ->
            @execute
              code_skipped: 2
              cmd: "#{adm_cmd} -d #{options.database} -tAc '\\dt';"
            , (err, status, stdout, stderr) ->
              throw err if err
              throw Error "Database does not exist #{options.database}" if !err and !status
          @execute
            cmd: "#{adm_cmd} -d #{options.database} -tAc \"CREATE SCHEMA #{options.schema};\""
            unless_exec: "#{adm_cmd} -d #{options.database} -tAc \"SELECT 1 FROM pg_namespace WHERE nspname = '#{options.schema}';\" | grep 1"
          # Check if owner is the good one
          @call 
            if: -> options.owner?
            handler: (_, cb) ->
              @execute 
                code_skipped: 1
                cmd: "#{adm_cmd} -d #{options.database} -tAc \"ALTER SCHEMA #{options.schema} OWNER TO #{options.owner};\" "
                unless_exec: "#{adm_cmd} -d #{options.database} -tAc '\\dn' | grep '#{options.schema}|#{options.owner}'"
              , (err, status , stdout, stderr) ->
                return cb Error "Owner #{options.owner} does not exists" if /^ERROR:\s\srole.*does\snot\sexist/.test stderr
                cb null, status
          @call
            if: -> @status(-1) or @status(-2)
            handler: -> modified =  true
      @then (err) -> callback err, modified
