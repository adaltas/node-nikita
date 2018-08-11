
# `nikita.ldap.acl`

Create new [ACLs](acls) for the OpenLDAP server.

## Options

* `to`   
  What to control access to as a string.   
* `place_before`   
  Place before another rule defined by "to".   
* `by`   
  Who to grant access to and the access to grant as an array
  (eg: `{..., by:["ssf=64 anonymous auth"]}`).   
* `first`   
* `url`   
  Specify URI referring to the ldap server.   
* `binddn`   
  Distinguished Name to bind to the LDAP directory.   
* `passwd`   
  Password for simple authentication.   
* `name`   
  Distinguish name storing the "olcAccess" property, using the database adress
  (eg: "olcDatabase={2}bdb,cn=config").   
* `overwrite`   
  Overwrite existing "olcAccess", default is to merge.   
* `log`   
  Function called with a log related messages.   
* `acl`   
  In case of multiple acls, regroup "place_before", "to" and "by" as an array.   

## Example

```js
require('nikita').ldap.acl({
  url: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'olcDatabase={2}bdb,cn=config',
  acls: [{
    place_before: 'dn.subtree="dc=domain,dc=com"',
    to: 'dn.subtree="ou=users,dc=domain,dc=com"',
    by: [
      'dn.exact="ou=users,dc=domain,dc=com" write',
      'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read',
      '* none'
    ]
  },{
    to: 'dn.subtree="dc=domain,dc=com"',
    by: [
      'dn.exact="ou=kerberos,dc=domain,dc=com" write'
    ]
  }]
}, function(err, modified){
  console.log(err ? err.message : 'ACL modified: ' + !!modified);
});
```

## Source Code

    module.exports = (options, callback) ->
      # # Auth related options
      # binddn = if options.binddn then "-D #{options.binddn}" else ''
      # passwd = if options.passwd then "-w #{options.passwd}" else ''
      # options.uri = 'ldapi:///' if options.uri is true
      # uri = if options.uri then "-H #{options.uri}" else '' # URI is obtained from local openldap conf unless provided
      # Acl related options
      options.acls ?= [{}]
      modified = false
      each(options.acls)
      .call (acl, callback) =>
        do_getdn = =>
          return do_getacls() if options.hdb_dn
          @log message: "Get DN of the HDB to modify", level: 'DEBUG', module: 'nikita/ldap/acl'
          @system.execute
            cmd: """
            ldapsearch -LLL -Y EXTERNAL -H ldapi:/// \
              -b cn=config \
              "(olcSuffix= #{options.suffix})" dn \
              2>/dev/null \
              | egrep '^dn' \
              | sed -e 's/^dn:\\s*olcDatabase=\\(.*\\)$/\\1/g'
            """
          , (err, data) ->
            return callback err if err
            options.hdb_dn = data.stdout.trim()
            do_getacls()
        do_getacls = =>
          @log message: "List all ACL of the directory", level: 'DEBUG', module: 'nikita/ldap/acl'
          @system.execute
            cmd: """
            ldapsearch -LLL -Y EXTERNAL -H ldapi:/// \
              -b olcDatabase=#{options.hdb_dn} \
              "(olcAccess=*)" olcAccess
            """
          , (err, data) ->
            return callback err if err
            current = null
            olcAccesses = []
            for line in string.lines data.stdout
              if match = /^olcAccess: (.*)$/.exec line
                olcAccesses.push current if current? # Push previous rule
                current = match[1] # Create new rule
              else if current?
                if /^ /.test line # Append to existing rule
                  current += line.substr 1
                else # Close the rule
                  olcAccesses.push current
                  current = null
            do_diff ldap.acl.parse olcAccesses
        do_diff = (olcAccesses) =>
          olcAccess = null
          # Find match "to" property
          for access, i in olcAccesses
            if acl.to is access.to
              olcAccess = misc.object.clone access
              olcAccess.old = access
              break
          if olcAccess # Modify rule or bypass perfect match
            is_perfect_match = true
            not_found_acl = []
            if acl.by.length isnt olcAccess.by.length
              is_perfect_match = false
            else
              for acl_by, i in acl.by
                is_perfect_match = false if acl_by isnt olcAccess.by[i]
                found = true
                for access_by in olcAccess.by
                  found = false if acl_by isnt access_by
                not_found_acl.push acl_by unless found
            if is_perfect_match
              @log message: "No modification to apply", level: 'INFO', module: 'nikita/ldap/acl'
              return do_end()
            if not_found_acl.length
              @log message: "Modify access after undefined acl", level: 'INFO', module: 'nikita/ldap/acl'
              for access_by in olcAccess.by
                not_found_acl.push access_by
              olcAccess.by = not_found_acl
            else
              @log message: "Modify access after reorder", level: 'INFO', module: 'nikita/ldap/acl'
              @log? 'nikita `ldap.acl`: m'
              olcAccess.by = acl.by
          else
            @log message: "Insert a new access", level: 'INFO', module: 'nikita/ldap/acl'
            index = olcAccesses.length
            if acl.first # not tested
              index = 0
            if acl.place_before
              for access, i in olcAccesses
                index = i if access.to is acl.place_before
            else if acl.after
              for access, i in olcAccesses
                index = i+1 if access.to is options.after
            olcAccess = index: index, to: acl.to, by: acl.by, add: true
          do_save olcAccess
        do_save = (olcAccess) =>
          old = ldap.acl.stringify olcAccess.old if olcAccess.old
          olcAccess = ldap.acl.stringify olcAccess
          if old
            cmd = """
            ldapadd -Y EXTERNAL -H ldapi:/// <<-EOF
            dn: olcDatabase=#{options.hdb_dn}
            changetype: modify
            delete: olcAccess
            olcAccess: #{old}
            -
            add: olcAccess
            olcAccess: #{olcAccess}
            EOF
            """
          else
            cmd = """
            ldapadd -Y EXTERNAL -H ldapi:/// <<-EOF
            dn: olcDatabase=#{options.hdb_dn}
            changetype: modify
            add: olcAccess
            olcAccess: #{olcAccess}
            EOF
            """
          @system.execute
            cmd: cmd
          , (err, data) ->
            return callback err if err
            modified = true
            do_end()
        do_end = ->
          callback()
        do_getdn()
      .next (err) ->
        callback err, modified

## Dependencies

    each = require 'each'
    misc = require '../misc'
    ldap = require '../misc/ldap'
    string = require '../misc/string'

[acls]: http://www.openldap.org/doc/admin24/access-control.html
[tuto]: https://documentation.fusiondirectory.org/fr/documentation/convert_acl
