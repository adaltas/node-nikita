
# `nikita.krb5.execute(options, [callback])`

Execute a Kerberos command.

## Options

* `admin.server`   
  Address of the kadmin server; optional, use "kadmin.local" if missing.   
* `admin.principal`   
  KAdmin principal name unless `kadmin.local` is used.   
* `admin.password`   
  Password associated to the KAdmin principal.   
* `principal`   
  Principal to be created.   
* `keytab`   
  Path to the file storing key entries.   

## Example

```
require('nikita')
.krb5_delrinc({
  principal: 'myservice/my.fqdn@MY.REALM',
  keytab: '/etc/security/keytabs/my.service.keytab',
  admin: {
    principal: 'me/admin@MY_REALM',
    password: 'pass',
    server: 'localhost'
  }
}, function(err, status){
  console.info(err ? err.message : 'Principal removed: ' + status);
});
```

## Schema

    schema =
      type: 'object'
      properties:
        'admin':
          type: 'object'
          properties:
            'realm': type: 'string'
            'principal': type: 'string'
            'server': type: 'string'
            'password': type: 'string'
        'cmd': type: 'string'
        'grep': type: 'string'
        'egrep': instanceof: 'RegExp'
      required: [
        'admin', 'cmd'
      ]

## Hooks

    on_options = ({options}) ->
      # Import all properties from `options.krb5`
      if options.krb5
        mutate options, options.krb5
        delete options.krb5
      if regexp.is options.grep
        options.egrep = options.grep
        delete options.grep

## Handler

    handler = ({options}, callback) ->
      realm = if options.admin.realm then "-r #{options.admin.realm}" else ''
      @system.execute
        cmd: if options.admin.principal
        then "kadmin #{realm} -p #{options.admin.principal} -s #{options.admin.server} -w #{options.admin.password} -q '#{options.cmd}'"
        else "kadmin.local #{realm} -q '#{options.cmd}'"
      , (err, {stdout}) ->
        return callback err if err
        if options.grep
          return callback null, stdout: stdout, status: stdout.split('\n').some (line) -> line is options.grep
        if options.egrep
          return callback null, stdout: stdout, status: stdout.split('\n').some (line) -> options.egrep.test line
        callback null, status: true, stdout: stdout

## Export

    module.exports =
      handler: handler
      on_options: on_options
      schema: schema

## Dependencies

    {mutate} = require 'mixme'
    {regexp} = require '@nikitajs/core/lib/misc'
