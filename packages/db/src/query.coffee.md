
# `nikita.db.user.query`

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
* `port`   
  Port to the associated database.   

## Schema

    schema =
      type: 'object'
      properties:
        'admin_username': type: 'string'
        'admin_password': type: 'string'
        'database': type: ['null', 'string'], default: null
        'grep': type: 'string'
        'egrep': instanceof: 'RegExp'
        'engine': type: 'string', enum: ['mariadb', 'mysql', 'postgres', 'postgresql']
        'host': type: 'string'
        'port': type: 'integer'
        'silent': type: 'boolean', default: true
        'trim': type: 'boolean', default: false
      required: [
        'admin_password', 'cmd'
        'engine', 'host', 'admin_username' ]

## Hooks

    on_options = ({options}) ->
      # Import all properties from `options.db`
      options[k] ?= v for k, v of options.db or {}
      # throw Error 'Required Option: "admin_password"' if options.admin_username and not options.admin_password
      # throw Error 'Required Option: "password"' if options.username and not options.password
      # throw Error 'Required Option: "admin_username" or "username"' if not options.admin_username and not options.username
      # options.admin_password = null unless options.admin_username
      if regexp.is options.grep
        options.egrep = options.grep
        delete options.grep
      options.engine = options.engine?.toLowerCase()
      options.port = parseInt options.port if typeof options.port is 'string' and /^\d+$/.test options.port
      if options.engine is 'postgres'
        console.log 'Deprecated Value: options "postgres" is deprecated in favor of "postgresql"'
        options.engine = 'postgresql'

## Handler

    handler = ({options}, callback) ->
      @system.execute
        cmd: cmd options
        # code_skipped: options.code_skipped
        trim: options.trim
      , (err, {stdout}) ->
        return callback err if err
        if options.grep
          return callback null, stdout: stdout, status: stdout.split('\n').some (line) -> line is options.grep
        if options.egrep
          return callback null, stdout: stdout, status: stdout.split('\n').some (line) -> options.egrep.test line
        callback null, stdout: stdout
        
## Escape

Escape SQL for Bash processing.

    escape = (sql) ->
      sql.replace /[\\"]/g, "\\$&"

## Command

Build the CLI query command.

    cmd = (...opts) ->
      options = {}
      for opt in opts
        opt = cmd: opt if typeof opt is 'string'
        for k, v of opt
          options[k] = v
      switch options.engine
        when 'mariadb', 'mysql'
          options.path ?= 'mysql'
          options.port ?= '3306'
          [
            "mysql"
            "-h#{options.host}"
            "-P#{options.port}"
            "-u#{options.admin_username}"
            "-p'#{options.admin_password}'"
            "-D#{options.database}" if options.database
            "#{options.mysql_options}" if options.mysql_options
            # -N, --skip-column-names   Don't write column names in results.
            # -s, --silent              Be more silent. Print results with a tab as separator, each row on new line.
            # -r, --raw                 Write fields without conversion. Used with --batch.
            "-N -s -r" if options.silent
            "-e \"#{escape options.cmd}\"" if options.cmd
          ].join ' '
        when 'postgresql'
          options.path ?= 'psql'
          options.port ?= '5432'
          [
            "PGPASSWORD=#{options.admin_password}"
            "psql"
            "-h #{options.host}"
            "-p #{options.port}"
            "-U #{options.admin_username}"
            "-d #{options.database}" if options.database
            "#{options.postgres_options}" if options.postgres_options
            # -t, --tuples-only        Print rows only
            # -A, --no-align           Unaligned table output mode
            # -q, --quiet              Run quietly (no messages, only query output)
            "-tAq"
            "-c \"#{options.cmd}\"" if options.cmd
          ].join ' '
        else
          throw Error "Unsupported engine: #{JSON.stringify options.engine}"
          
## Parse JDBC URL

Enrich the result of `url.parse` with the "engine" and "db" properties.

Exemple:

```
parse 'jdbc:mysql://host1:3306,host2:3306/hive?createDatabaseIfNotExist=true'
{ engine: 'mysql',
  addresses:
   [ { host: 'host1', port: '3306' },
     { host: 'host2', port: '3306' } ],
  database: 'hive' }
```

    jdbc = (jdbc) ->
      if /^jdbc:mysql:/.test jdbc
        [_, engine, addresses, database] = /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec jdbc
        addresses = addresses.split(',').map (address) ->
          [host, port] = address.split ':'
          host: host, port: port or 3306
        engine: 'mysql'
        addresses: addresses
        database: database
      else if /^jdbc:postgresql:/.test jdbc
        [_, engine, addresses, database] = /^jdbc:(.*?):\/+(.*?)\/(.*?)(\?(.*)|$)/.exec jdbc
        addresses = addresses.split(',').map (address) ->
          [host, port] = address.split ':'
          host: host, port: port or 5432
        engine: 'postgresql'
        addresses: addresses
        database: database
      else
        throw Error 'Invalid JDBC URL'

## Copy options

    connection_options = (opts) ->
      options = {}
      for k, v of opts
        continue unless k in ['admin_username', 'admin_password', 'database', 'engine', 'host', 'port', 'silent']
        options[k] = v
      options

## Exports

    module.exports =
      on_options: on_options
      handler: handler
      schema: schema
      cmd: cmd
      # Utils
      connection_options: connection_options
      escape: escape
      jdbc: jdbc

## Dependencies

    {regexp} = require '@nikitajs/core/lib/misc'
