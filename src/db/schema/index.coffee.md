
# `mecano.db.schema(options, callback)`

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

## Create Schema example

```js
require('mecano').database.schema({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db',
}, function(err, modified){
  console.log(err ? err.message : 'Principal created or modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Check main options
      throw Error 'Missing option: "host"' unless options.host
      throw Error 'Missing option: "admin_username"' unless options.admin_username
      throw Error 'Missing option: "admin_password"' unless options.admin_password
      throw Error 'Missing option: "database"' unless options.database
      throw Error 'Missing option: "engine"' unless options.engine
      # Defines and check the engine type 
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['postgres']
      # Options
      options.port ?= 5432 
      @system.execute
        code_skipped: 2
        cmd: db.cmd options, '\\dt'
      , (err, status, stdout, stderr) ->
        throw err if err
        throw Error "Database does not exist #{options.database}" if !err and !status
      @system.execute
        cmd: db.cmd options, "CREATE SCHEMA #{options.schema};"
        unless_exec: db.cmd(options, "SELECT 1 FROM pg_namespace WHERE nspname = '#{options.schema}';") + " | grep 1"
      # Check if owner is the good one
      @system.execute 
        if: -> options.owner?
        unless_exec: db.cmd(options, '\\dn') + " | grep '#{options.schema}|#{options.owner}'"
        cmd: db.cmd options, "ALTER SCHEMA #{options.schema} OWNER TO #{options.owner};"
        code_skipped: 1
      , (err, status , stdout, stderr) ->
        throw Error "Owner #{options.owner} does not exists" if /^ERROR:\s\srole.*does\snot\sexist/.test stderr

## Dependencies

    db = require '../../misc/db'
