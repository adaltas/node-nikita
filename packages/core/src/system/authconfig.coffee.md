
# `nikita.system.authconfig`

authconfig provides a simple method of configuring /etc/sysconfig/network to handle NIS, as well as /etc/passwd and /etc/shadow, the files used for shadow password support. Basic LDAP, Kerberos 5, and Winbind client configuration is also provided. 

## Options

* `config` (object)   
  Key/value pairs of the properties to manage.

## Example

Example of a group object

```cson
require('nikita')
.system.authconfig({
  config: {
    mkhomedir: true
  }
}, (err, {status}){
  console.info(err ? err.message : 'Config' + 
    status ? 'updated' : 'already set')
  })
```

## Source Code

    module.exports = ({options}) ->
      @log message: "Entering authconfig", level: 'DEBUG', module: 'nikita/lib/system/authconfig'
      throw Error 'Required Option: the `config` option is required' unless options.config
      before = after = null
      @system.execute
        shy: true
        cmd: [ 'authconfig', '--test' ].join ' '
        trim: true
      , (err, {stdout}) ->
        before = stdout
      @system.execute
        shy: true
        cmd: [
          'authconfig', '--update'
          ...(
            Object.keys(options.config).map (key) ->
              if options.config[key]
              then "--enable#{key}"
              else "--disable#{key}"
          )
        ].join ' '
      @system.execute
        shy: true
        cmd: [ 'authconfig', '--test' ].join ' '
        trim: true
      , (err, {stdout}) ->
        after = stdout
      @call ({}, callback)->
        changes = diff.diffLines before, after, ignoreWhitespace: true
        callback null, changes.some (d) -> d.added or d.removed

    diff = require 'diff'
