
# `exists(options, callback)`

Chek is user exists in the database.

## Options

*   `admin_username`   
    The login of the database administrator. It should have credentials to create accounts.
*   `admin_password`   
    The password of the database administrator.
    provided.
*   `database` (String)
    The database name to which the user should be added
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
*   `user` String   
    User name.
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

## Keytab example

```js
require('mecano').krb5.addprinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  randkey: true,
  keytab: '/etc/security/keytabs/my.service.keytab',
  uid: 'myservice',
  gid: 'myservice',
  kadmin_principal: 'me/admin@MY_REALM',
  kadmin_password: 'pass',
  kadmin_server: 'localhost'
}, function(err, modified){
  console.log(err ? err.message : 'Principal created or modified: ' + !!modified);
});
```

## Source Code

    module.exports = shy: true, handler: (options, callback) ->
      # Import options from `options.db`
      options.db ?= {}
      options[k] ?= v for k, v of options.db
      # Check main options
      return callback new Error 'Missing hostname' unless options.host?
      return callback new Error 'Missing admin name' unless options.admin_username?
      return callback new Error 'Missing admin password' unless options.admin_password?
      return callback new Error 'Missing name' unless options.name?    
      # Defines and check the engine type 
      options.engine = options.engine.toUpperCase() if options.engine?
      options.engine ?= 'POSTGRES'
      return callback new Error 'Unsupported engine type' unless options.engine in ['MYSQL','POSTGRES']
      options.log message: "Database engine set to #{options.engine}", level: 'INFO', module: 'mecano/database/db/user'
      # Defines port
      options.port ?= 5432      
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
      @execute
        cmd: "#{adm_cmd} -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{options.name}'\" | grep 1"
        code_skipped: 1
      , (err, status, stdout, stderr) -> callback err, status, stdout, stderr 
