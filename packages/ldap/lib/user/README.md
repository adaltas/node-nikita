
# `nikita.ldap.user`

Create and modify a user store inside an OpenLDAP server.   

## Example

```js
const {$status} = await nikita.ldap.user({
  uri: 'ldap://openldap.server/',
  binddn: 'cn=admin,cn=config',
  passwd: 'password',
  user: {}
})
console.info(`User created or modified: ${$status}`)
```

## User password update

Note, a user can modify it's own password with the "ldappasswd" command if ACL allows it. Here's an example:

```bash
ldappasswd -D cn=myself,ou=users,dc=ryba -w oldpassword \
  -H ldaps://master3.ryba:636 \
  -s newpassword 'cn=myself,ou=users,dc=ryba'
```
