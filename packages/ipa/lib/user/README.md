
# `nikita.ipa.user`

Add or modify a user in FreeIPA.

## Implementation

The `userpassword` attribute is only used on user creation. To force the
password to be re-initialized on user update, pass the `force_userpassword`
option.

## Example

```js
const {$status} = await nikita.ipa.user({
  uid: "someone",
  attributes: {
    noprivate: true,
    gidnumber: 1000,
    userpassword: "secret"
  },
  connection: {
    url: "https://ipa.domain.com/ipa/session/json",
    principal: "admin@DOMAIN.COM",
    password: "mysecret"
  }
})
console.info(`User was updated: ${$status}`)
```
