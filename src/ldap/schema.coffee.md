
# `nikita.ldap.schema(options, [callback])`

Register a new ldap schema.

## Options

* `binddn`   
  Distinguished Name to bind to the LDAP directory.   
* `passwd`   
  Password for simple authentication.   
* `uri`   
  LDAP Uniform Resource Identifier(s), "ldapi:///" if true, default to false
  in which case it will use your openldap client environment configuration.   
* `name`   
  Common name of the schema.   
* `schema`   
  Path to the schema definition.   
* `overwrite`   
  Overwrite existing "olcAccess", default is to merge.   
* `log`   
  Function called with a log related messages.   
* `ssh` (object|ssh2)   
  Run the action on a remote server using SSH, an ssh2 instance or an
  configuration object used to initialize the SSH connection.   
* `stdout` (stream.Writable)   
  Writable EventEmitter in which the standard output of executed commands will
  be piped.   
* `stderr` (stream.Writable)   
  Writable EventEmitter in which the standard error output of executed command
  will be piped.   

## Example

```js
require('nikita').ldap.schema({
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'kerberos',
  schema: '/usr/share/doc/krb5-server-ldap-1.10.3/kerberos.schema'
}, function(err, modified){
  console.log(err ? err.message : 'Index modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options) ->
      options.log message: "Entering ldap.schema", level: 'DEBUG', module: 'nikita/lib/ldap/schema'
      # SSH connection
      ssh = @ssh options.ssh
      # Auth related options
      binddn = if options.binddn then "-D #{options.binddn}" else ''
      passwd = if options.passwd then "-w #{options.passwd}" else ''
      if options.url
        console.log "Nikita: option 'options.url' is deprecated, use 'options.uri'"
        options.uri ?= options.url
      options.uri = 'ldapi:///' if options.uri is true
      uri = if options.uri then "-H #{options.uri}" else '' # URI is obtained from local openldap conf unless provided
      # Schema related options
      throw Error "Missing name" unless options.name
      throw Error "Missing schema" unless options.schema
      options.schema = options.schema.trim()
      tempdir = options.tempdir or "/tmp/nikita_ldap.schema_#{Date.now()}"
      schema = "#{tempdir}/#{options.name}.schema"
      conf = "#{tempdir}/schema.conf"
      ldif = "#{tempdir}/ldif"
      @system.execute
        # shy: true
        cmd: """
        ldapsearch -LLL #{binddn} #{passwd} #{uri} -b \"cn=schema,cn=config\" \
        | grep -E cn=\\{[0-9]+\\}#{options.name},cn=schema,cn=config
        """
        code: 1
        code_skipped: 0
      @call if: (-> @status -1), ->
        @system.mkdir
          target: ldif
          ssh: ssh
        , (err) ->
          options.log 'Directory ldif created'
        @system.copy
          source: options.schema
          target: schema
          ssh: ssh
        , (err) ->
          options.log 'Schema copied'
        @file
          content: "include #{schema}"
          target: conf
          ssh: ssh
          log: options.log
        , (err) ->
          options.log 'Configuration generated'
        @system.execute
          cmd: "slaptest -f #{conf} -F #{ldif}"
        , (err) ->
          options.log 'Configuration validated' unless err
        @system.move
          source: "#{ldif}/cn=config/cn=schema/cn={0}#{options.name}.ldif"
          target: "#{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif"
          force: true
        , (err, status) ->
          throw Error 'No generated schema' unless status
          options.log 'Configuration renamed'
        @file
          target: "#{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif"
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
        , (err) ->
          options.log "File ldif ready" unless err
        @system.execute
          cmd: "ldapadd #{uri} #{binddn} #{passwd} -f #{ldif}/cn=config/cn=schema/cn=#{options.name}.ldif"
        , (err) ->
          throw err if err
          options.log "Schema added: #{options.name}"
      @system.remove
        if: -> @status -1
        target: tempdir
