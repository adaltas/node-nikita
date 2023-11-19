
# Nikita "krb5" package

The "krb5" package provides Nikita actions for various Kerberos 5 operations.

## Usage

```js
import "@nikitajs/krb5/register";
import nikita from "@nikitajs/core";

const {$status} = await nikita.krb5.addprinc({
  principal: "nikita@DOMAIN.COM",
  randkey: true,
  admin: {
    server: "krb5.domain.com",
    principal: "admin/admin@DOMAIN.COM",
    password: "admin",
  },
});
console.info("Principal was modified:", $status);
```
