
# `exists(options, callback)`

Chek is user exists in the database.

## Options

*   `admin_name`   
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

    module.exports = (options, callback) ->
      # Check main options
      return callback new Error 'Missing hostname' unless options.host?
      return callback new Error 'Missing admin name' unless options.admin_name?
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
          adm_cmd += " -u #{options.admin_name}"
          adm_cmd += " -p #{options.admin_password}"
          break;
        when 'POSTGRES'
          #psql does not have any option
          adm_cmd += "PGPASSWORD=#{options.admin_password} psql"
          adm_cmd += " -h #{options.host}"
          adm_cmd += " -U #{options.admin_name}"
          break;
        else
          break;
      @execute
        cmd: "#{adm_cmd} -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{options.name}'\" | grep 1"
        code_skipped: 1
      , (err, status, stdout, stderr) -> callback err, status, stdout, stderr 
      #       
      #     
      #     
      #   
      #   
      # # Check if user exists
      # # Check id databases exists
      # # Check if user can connect to databases
      # 
      # return callback new Error 'Password or randkey missing' if not options.password and not options.randkey
      # # Normalize realm and principal for later usage of options
      # options.realm ?= options.kadmin_principal.split('@')[1] if /.*@.*/.test options.kadmin_principal
      # options.principal = "#{options.principal}@#{options.realm}" unless /^\S+@\S+$/.test options.principal
      # options.password_sync ?= false
      # options.kadmin_server ?= options.admin_server # Might deprecated kadmin_server in favor of admin_server
      # # Prepare commands
      # cmd_getprinc = misc.kadmin options, "getprinc #{options.principal}"
      # cmd_addprinc = misc.kadmin options, if options.password
      # then "addprinc -pw #{options.password} #{options.principal}"
      # else "addprinc -randkey #{options.principal}"
      # # todo, could be removed once actions acception multiple options arguments
      # # such ash `.krb5.ktadd options, if: options.keytab
      # ktadd_options = {}
      # for k, v of options then ktadd_options[k] = v
      # ktadd_options.if = options.keytab
      # # Ticket cache location
      # cache_name = "/tmp/mecano_#{Math.random()}"
      # @execute
      #   retry: 3
      #   cmd: cmd_addprinc
      #   unless_exec: "#{cmd_getprinc} | grep '#{options.principal}'"
      # @execute
      #   retry: 3
      #   cmd: misc.kadmin options, "cpw -pw #{options.password} #{options.principal}"
      #   if: options.password and options.password_sync
      #   unless_exec: """
      #   if ! echo #{options.password} | kinit '#{options.principal}' -c '#{cache_name}'; then exit 1; else kdestroy -c '#{cache_name}'; fi
      #   """
      # @krb5.ktadd ktadd_options
      # @then callback



## Dependencies

    misc = require '../../misc'
    postgres = require '../../misc/database'
    each = require 'each'
