
# `ldap_schema([goptions], options, callback)`

Register a new ldap schema.

## Options

*   `binddn`        Distinguished Name to bind to the LDAP directory, alternative to providing an [ldapjs client] instance.   
*   `passwd`        Password for simple authentication, alternative to providing an [ldapjs client] instance.   
*   `uri`           LDAP Uniform Resource Identifier(s), "ldapi:///" if true, default to false in which case it will use your openldap client environment configuraiton.   
*   `name`          Common name of the schema.   
*   `schema`        Path to the schema definition.   
*   `overwrite`     Overwrite existing "olcAccess", default is to merge.   
*   `log`           Function called with a log related messages.   

## Example

```js
require('mecano').ldap_schema({
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'kerberos',
  schema: '/usr/share/doc/krb5-server-ldap-1.10.3/kerberos.schema'
}, function(err, modified){
  console.log(err ? err.message : "Index modified: " + !!modified);
});
```

    module.exports = (goptions, options, callback) ->
      [goptions, options, callback] = misc.args arguments
      result = child()
      finish = (err, created) ->
        callback err, created if callback
        result.end err, created
      misc.options options, (err, options) ->
        return finish err if err
        modified = 0
        each( options )
        .parallel(goptions.parallel)
        .on 'item', (options, next) ->
          return next new Error "Missing name" unless options.name
          return next new Error "Missing schema" unless options.schema
          options.schema = options.schema.trim()
          tempdir = options.tempdir or "/tmp/mecano_ldap_schema_#{Date.now()}"
          schema = "#{tempdir}/#{options.name}.schema"
          conf = "#{tempdir}/schema.conf"
          ldif = "#{tempdir}/ldif"
          binddn = if options.binddn then "-D #{options.binddn}" else ''
          passwd = if options.passwd then "-w #{options.passwd}" else ''
          options.uri = 'ldapi:///' if options.uri is true
          uri = if options.uri then "-H #{options.uri}" else '' # URI is obtained from local openldap conf unless provided
          do_registered = ->
            cmd = "ldapsearch #{binddn} #{passwd} #{uri} -b \"cn=schema,cn=config\" | grep -E cn=\\{[0-9]+\\}#{options.name},cn=schema,cn=config"
            options.log? "Check if schema is registered: #{cmd}"
            execute
              cmd: cmd
              code: 0
              code_skipped: 1
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, registered, stdout) ->
              return next err if err
              return next() if registered
              do_dir()
          do_dir = ->
            options.log? 'Create ldif directory'
            mkdir
              destination: ldif
              ssh: options.ssh
            , (err, executed) ->
              return next err if err
              do_write()
          do_write = ->
            options.log? 'Copy schema'
            copy
              source: options.schema
              destination: schema
              ssh: options.ssh
            , (err, copied) ->
              return next err if err
              options.log? 'Prepare configuration'
              write
                content: "include #{schema}"
                destination: conf
                ssh: options.ssh
              , (err) ->
                return next err if err
                do_generate()
          do_generate = ->
            options.log? 'Generate configuration'
            execute
              cmd: "slaptest -f #{conf} -F #{ldif}"
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed) ->
              return next err if err
              do_rename()
          do_rename = ->
            options.log? 'Rename configuration'
            move
              source: "#{ldif}/cn=config/cn=schema/cn={0}#{options.name}.ldif"
              destination: "#{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif"
              force: true
              ssh: options.ssh
            , (err, moved) ->
              return next err if err
              return new Error 'No generated schema' unless moved
              do_configure()
          do_configure = ->
            options.log? 'Prepare ldif'
            write
              destination: "#{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif"
              write: [
                match: /^dn: cn.*$/mg
                replace: "dn: cn=#{options.name},cn=schema,cn=config"
              ,
                match: /^cn: {\d+}(.*)$/mg
                replace: 'cn: $1'
              ,
                match: /^structuralObjectClass.*/mg
                replace: ''
              ,
                match: /^entryUUID.*/mg
                replace: ''
              ,
                match: /^creatorsName.*/mg
                replace: ''
              ,
                match: /^createTimestamp.*/mg
                replace: ''
              ,
                match: /^entryCSN.*/mg
                replace: ''
              ,
                match: /^modifiersName.*/mg
                replace: ''
              ,
                match: /^modifyTimestamp.*/mg
                replace: ''
              ]
              ssh: options.ssh
            , (err, written) ->
              return next err if err
              do_register()
          do_register = ->
            # uri = if options.uri then"-L #{options.uri}" else ''
            # binddn = if options.binddn then "-D #{options.binddn}" else ''
            # passwd = if options.passwd then "-w #{options.passwd}" else ''
            cmd = "ldapadd #{uri} #{binddn} #{passwd} -f #{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif"
            options.log? "Add schema: #{cmd}"
            execute
              cmd: cmd
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, executed) ->
              return next err if err
              modified++
              do_clean()
          do_clean = ->
            options.log? 'Clean up'
            remove
              destination: tempdir
              ssh: options.ssh
            , (err, removed) ->
              next err
          conditions.all options, next, do_registered
        .on 'both', (err) ->
          finish err, modified
      result

## Dependencies

    each = require 'each'
    ldap = require 'ldapjs'
    misc = require './misc'
    conditions = require './misc/conditions'
    child = require './misc/child'
    execute = require './execute'
    copy = require './copy'
    write = require './write'
    move = require './move'
    remove = require './remove'
    mkdir = require './mkdir'




