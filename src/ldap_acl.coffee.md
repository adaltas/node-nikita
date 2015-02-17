
# `ldap_acl(options, [goptions], callback)`

Create new [ACLs](acls) for the OpenLDAP server.   

## Options

*   `to`   
    What to control access to as a string.   
*   `by`   
    Who to grant access to and the access to grant as an array
    (eg: `{..., by:["ssf=64 anonymous auth"]}`).   
*   `url`   
    Specify URI referring to the ldap server.   
*   `binddn`   
    Distinguished Name to bind to the LDAP directory.   
*   `passwd`   
    Password for simple authentication.   
*   `name`   
    Distinguish name storing the "olcAccess" property, using the database adress
    (eg: "olcDatabase={2}bdb,cn=config").   
*   `overwrite`   
    Overwrite existing "olcAccess", default is to merge.   
*   `log`   
    Function called with a log related messages.   
*   `acl`   
    In case of multiple acls, regroup "before", "to" and "by" as an array.   

## Example

```js
require('mecano').ldap_acl({
  url: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  name: 'olcDatabase={2}bdb,cn=config',
  acls: [{
    before: 'dn.subtree="dc=domain,dc=com"',
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
      wrap @, arguments, (options, callback) ->
        options.acls ?= [{}]
        modified = false
        each(options.acls)
        .parallel(false)
        .on 'item', (acl, callback) ->
          do_getdn = ->
            return do_getacls() if options.hdb_dn
            options.log? "mecano `ldap_acl`: get DN of the HDB to modify"
            execute
              cmd: """
              ldapsearch -Y EXTERNAL -H ldapi:/// \
                -b cn=config \
                "(olcSuffix= #{options.suffix})" dn \
                2>/dev/null \
                | egrep '^dn' \
                | sed -e 's/^dn:\\s*olcDatabase=\\(.*\\)$/\\1/g'
              """
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, _, hdb_dn) ->
              return callback err if err
              options.hdb_dn = hdb_dn.trim()
              do_getacls()
          do_getacls = ->
            options.log? "mecano `ldap_acl`: list all ACL of the directory"
            execute
              cmd: """
              ldapsearch -Y EXTERNAL -H ldapi:/// \
                -b olcDatabase=#{options.hdb_dn} \
                "(olcAccess=*)" olcAccess
              """
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, _, stdout) ->
              return callback err if err
              current = null
              olcAccesses = []
              for line in string.lines stdout
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
          do_diff = (olcAccesses) ->
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
                options.log? 'mecano `ldap_acl`: no modification to apply'
                return do_end()
              if not_found_acl.length
                options.log? 'mecano `ldap_acl`: modify access after undefined acl'
                for access_by in olcAccess.by
                  not_found_acl.push access_by
                olcAccess.by = not_found_acl
              else
                options.log? 'mecano `ldap_acl`: modify access after reorder'
                olcAccess.by = acl.by
            else
              options.log? 'mecano `ldap_acl`: insert a new access'
              index = olcAccesses.length
              if acl.before
                for access, i in olcAccesses
                  index = i if access.to is acl.before
              else if acl.after
                for access, i in olcAccesses
                  index = i+1 if access.to is options.after
              olcAccess = index: index, to: acl.to, by: acl.by, add: true
            do_save olcAccess
          do_save = (olcAccess) ->
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
            execute
              cmd: cmd
              ssh: options.ssh
              log: options.log
              stdout: options.stdout
              stderr: options.stderr
            , (err, _, hdb_dn) ->
              return callback err if err
              modified = true
              do_end()
          do_end = ->
            callback()
          do_getdn()
        .on 'both', (err) ->
          callback err, modified

## Dependencies

    each = require 'each'
    misc = require './misc'
    ldap = require './misc/ldap'
    string = require './misc/string'
    wrap = require './misc/wrap'
    execute = require './execute'

[acls]: http://www.openldap.org/doc/admin24/access-control.html
[tuto]: https://documentation.fusiondirectory.org/fr/documentation/convert_acl


