
# Nikita "ldap" package

The "ldap" package provides Nikita actions for various OpenLDAP operations.

## Usage

```js
import "@nikitajs/ldap/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.ldap.add({
  // Connection
  uri: "ldap://openldap:389",
  binddn: "cn=admin,dc=domain,dc=com",
  passwd: "admin",
  // User information
  entry: {
    dn: "cn=nikita,dc=domain,dc=com",
    userPassword: "test",
    uid: "nikita",
    objectClass: [ "top", "account", "posixAccount", "shadowAccount" ],
    shadowLastChange: "15140",
    shadowMin: "0",
    shadowMax: "99999",
    shadowWarning: "7",
    loginShell: "/bin/bash",
    uidNumber: "9610",
    gidNumber: "9610",
    homeDirectory: "/home/nikita",
  },
});
console.info("Entry was modified:", $status);
```
