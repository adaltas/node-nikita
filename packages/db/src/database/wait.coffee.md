
# `nikita.db.database.wait`

Wait for the creation of a database.

## Options

* `admin_username`   
  The login of the database administrator.   
* `admin_password`   
  The password of the database administrator.   
* `database` (Array or String)   
  The database name to check for existance.   
* `engine`   
  The engine type, can be MySQL or PostgreSQL, required.   
* `host`   
  The hostname of the database.   
* `port`   
  Port to the associated database.   
* `user` Array or String   
  Contains  user(s) to add to the database, optional.   

## Create Database example

```js
require('nikita')
.database.db.wait({
  admin_username: 'test',
  admin_password: 'test',
  database: 'my_db'
}, function(err, {status}){
  console.info(err ? err.message : 'Did database existed initially: ' + !status);
});
```

## Source Code

    module.exports = ({metadata, options}) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      options.database ?= metadata.argument
      # Deprecation
      if options.engine is 'postgres'
        console.log 'Deprecated Value: options "postgres" is deprecated in favor of "postgresql"'
        options.engine = 'postgresql'
      # Defines and check the engine type
      options.engine = options.engine.toLowerCase()
      throw Error "Unsupport engine: #{JSON.stringify options.engine}" unless options.engine in ['mariadb', 'mysql', 'postgresql']
      # Command
      @wait.execute
        cmd: switch options.engine
          when 'mariadb', 'mysql'
            cmd(options, database: null, "show databases") + " | grep '#{options.database}'"
          when 'postgresql'
            cmd(options, database: null, null) + " -l | cut -d \\| -f 1 | grep -qw '#{options.database}'"

## Dependencies

    {cmd} = require '../query'
